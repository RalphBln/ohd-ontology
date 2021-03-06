;;****************************************************************
;; Instructions for being able to connect to Eaglesoft database
;;
;; Ensure that the r21 system file is loaded.
;; For details see comment at top of r21-utilities.lisp

;;****************************************************************
;; Database preparation: 
;; When get-eaglesoft-dental-patients-ont is ran, the program verifies that the action_codes and
;; patient_history tables exist.  This is done by calling prepare-eaglesoft-db.  However, this
;; only tests that these tables exist in the user's database. If these table need to be 
;; recreated, the call get-eaglesoft-fillings-ont with :force-create-table key set to t.

;; the global variables are used to generate unique iri's



(defun get-eaglesoft-dental-patients-ont (&key patient-id limit-rows force-create-table)
  "Returns an ontology of the dental patients contained in the Eaglesoft database. The patient-id key creates an ontology based on that specific patient. The limit-rows key restricts the number of records returned from the database.  It is primarily used for testing. The force-create-table key is used to force the program to recreate the actions_codes and patient_history tables."
  (let ((results nil)
	(query nil)
	(count 0))
    
    ;; verify that the eaglesoft db has the action_codes and patient_history tables
    (prepare-eaglesoft-db :force-create-table force-create-table)

    ;; get query string for amalgam restorations
    (setf query (get-eaglesoft-dental-patients-query 
		 :patient-id patient-id :limit-rows limit-rows))

    (with-ontology ont (:collecting t 
			:base *eaglesoft-individual-dental-patients-iri-base*
			:ontology-iri *eaglesoft-dental-patients-ontology-iri*) 
	(;; import the ohd ontology
	 (as `(imports ,(make-uri *ohd-ontology-iri*)))

	 ;; get axioms for declaring annotation, object, and data properties used for ohd
	 (as (get-ohd-declaration-axioms))
	 
	 ;; get records from eaglesoft db and create axioms
	 (with-eaglesoft (results query)
	    (loop while (#"next" results) do
		 (as (get-eaglesoft-dental-patient-axioms
		      (#"getString" results "patient_id")
		      (#"getString" results "birth_date")
		      (#"getString" results "sex")))
		 (incf count))))

      ;; return the ontology
      (values ont count))))


(defun get-eaglesoft-dental-patient-axioms (patient-id birth-date sex)
  "Returns a list of axioms about a patient that is identified by patient-id, birth date, and sex."
  (let ((axioms nil)
	(patient-uri nil))

    ;; create instance/indiviual  patient, note this dependent on the patients sex
    ;; if sex is not present; we will skip the record
    (when (or (equalp sex "F") (equalp sex "M"))
      ;; create uri for individual patient
      (setf patient-uri (get-eaglesoft-dental-patient-iri patient-id))
      (push `(declaration (named-individual ,patient-uri)) axioms) 
      
      ;; declare patient to be an instance of Female or Male 
      ;; note: append puts lists together and doesn't put items in list (like push)
      (cond
	((equalp sex "F")
	 (setf axioms
	       (append (get-ohd-instance-axioms patient-uri !'female dental patient'@ohd) axioms)))
	(t	 
	 (setf axioms
	       (append (get-ohd-instance-axioms patient-uri !'male dental patient'@ohd) axioms))))

      
      ;; add data property 'patient id' to patient
      (push `(data-property-assertion !'patient ID'@ohd 
				      ,patient-uri 
				      ,patient-id) axioms)

      ;; add data propert about patient's birth date
      (push `(data-property-assertion !'birth_date'@ohd ,patient-uri 
				      (:literal ,birth-date !xsd:date)) axioms)

      ;; add label annotation about patient
      (push `(annotation-assertion !rdfs:label 
				   ,patient-uri 
				   ,(str+ "patient " patient-id)) axioms)

      ;; add axioms about dental patient role
      ;; note: append puts lists together and doesn't put items in list (like push)
      (setf axioms 
	    (append (get-eaglesoft-dental-patient-role-axioms patient-uri patient-id) axioms)))

    ;;(pprint axioms)
    ;; return axioms
    axioms))

(defun get-eaglesoft-dental-patient-role-axioms (patient-uri patient-id)
  "Returns a list of axioms about a dental patient's role."
  (let ((axioms nil)
	(patient-role-uri))
    ;; create uri
    (setf patient-role-uri (get-eaglesoft-dental-patient-role-iri patient-id))

    ;; create instance of patient role; patient role is an instance of !obi:'patient role'
    ;; note: append puts lists together and doesn't put items in list (like push)
    (push `(declaration (named-individual ,patient-role-uri)) axioms)
    ;;(push `(class-assertion !'patient role'@ohd ,patient-role-uri) axioms) 
    (setf axioms 
	  (get-ohd-instance-axioms patient-role-uri !'patient role'@ohd))

    

    ;; 'patient role' inheres in patient
    (push `(object-property-assertion !'inheres in'@ohd
				      ,patient-role-uri ,patient-uri) axioms)

    ;; add label annotation about patient role
    (push `(annotation-assertion !rdfs:label 
				 ,patient-role-uri 
				 ,(str+ "'patient role' for patient " 
					 patient-id)) axioms)
    ;; return axioms
    axioms))


(defun get-eaglesoft-dental-patients-query (&key patient-id limit-rows)
  "Returns query string for retrieving data. The patient-id key restricts records only that patient or patients.  Multiple are patients are specified using commas; e.g: \"123, 456, 789\".  The limit-rows key restricts the number of records to the number specified."
  (let ((sql nil))

    ;; build query string
    (setf sql "SET rowcount 0 ")
    
    ;; SELECT clause
    (cond 
      (limit-rows
       (setf limit-rows (format nil "~a" limit-rows)) ;ensure that limit rows is a string
       (setf sql (str+ sql " SELECT  DISTINCT TOP " limit-rows " patient_id, birth_date, sex "))) 
      (t (setf sql (str+ sql " SELECT DISTINCT patient_id, birth_date, sex "))))

    ;; FROM clause
    (setf sql (str+ sql " FROM patient_history "))

    ;; WHERE clause
    (setf sql (str+ sql " WHERE LENGTH(birth_date) > 0 "))

    ;; check for patient id
    (when patient-id
      (setf sql
	    (str+ sql " AND patient_id IN (" (get-single-quoted-list patient-id) ") ")))

    ;; ORDER BY clause
    (setf sql (str+ sql " ORDER BY patient_id "))

    ;; return query string
    ;;(pprint sql)
    sql))
