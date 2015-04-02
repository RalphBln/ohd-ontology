prefixes = new.env(hash=TRUE)
assign("rdf:", "<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",prefixes)
assign("rdfs:", "<http://www.w3.org/2000/01/rdf-schema#>",envir=prefixes)
assign("owl:", "<http://www.w3.org/2002/07/owl#>",envir=prefixes)
assign("obo:", "<http://purl.obolibrary.org/obo/>",envir=prefixes)
assign("dental_patient:", "<http://purl.obolibrary.org/obo/OHD_0000012>",envir=prefixes)
assign("birth_date:", " <http://purl.obolibrary.org/obo/OHD_0000050>",envir=prefixes)
assign("occurrence_date:", " <http://purl.obolibrary.org/obo/OHD_0000015>",envir=prefixes)
assign("inheres_in:", "<http://purl.obolibrary.org/obo/BFO_0000052>",envir=prefixes)
assign("participates_in:", "<http://purl.obolibrary.org/obo/BFO_0000056>",envir=prefixes)
assign("has_participant:", "<http://purl.obolibrary.org/obo/BFO_0000057>",envir=prefixes)
assign("dental_procedure:", "<http://purl.obolibrary.org/obo/OHD_0000002>",envir=prefixes)
assign("crown_restoration:", "<http://purl.obolibrary.org/obo/OHD_0000033>",envir=prefixes)
assign("tooth_restoration_procedure:", "<http://purl.obolibrary.org/obo/OHD_0000004>",envir=prefixes)
assign("intracoronal_restoration:", "<http://purl.obolibrary.org/obo/OHD_0000006>",envir=prefixes)
assign("veneer_restoration:", "<http://purl.obolibrary.org/obo/OHD_0000027>",envir=prefixes)
assign("inlay_restoration:", "<http://purl.obolibrary.org/obo/OHD_0000133>",envir=prefixes)
assign("onlay_restoration:", "<http://purl.obolibrary.org/obo/OHD_0000134>",envir=prefixes)
assign("surgical_procedure:", "<http://purl.obolibrary.org/obo/OHD_0000044>",envir=prefixes)
assign("endodontic_procedure:", "<http://purl.obolibrary.org/obo/OHD_0000003>",envir=prefixes)
assign("tooth_to_be_restored_role:", "<http://purl.obolibrary.org/obo/OHD_0000007>",envir=prefixes)
assign("dental_patient_role:", "<http://purl.obolibrary.org/obo/OHD_0000190>",envir=prefixes)
assign("patient_role:", "<http://purl.obolibrary.org/obo/OHD_0000190>",envir=prefixes)
assign("dental_healthcare_provider_role:", "<http://purl.obolibrary.org/obo/OHD_0000052>",envir=prefixes)
assign("tooth_to_be_filled_role:", "<http://purl.obolibrary.org/obo/OHD_0000008>",envir=prefixes)
assign("realizes:", "<http://purl.obolibrary.org/obo/BFO_0000055>",envir=prefixes)
assign("tooth:", "<http://purl.obolibrary.org/obo/FMA_12516>",envir=prefixes)
assign("is_part_of:", "<http://purl.obolibrary.org/obo/BFO_0000050>",envir=prefixes)
assign("tooth_surface:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Surface_enamel_of_tooth>",envir=prefixes)
assign("mesial:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Mesial_surface_enamel_of_tooth>",envir=prefixes)
assign("distal:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Distal_surface_enamel_of_tooth>",envir=prefixes)
assign("occlusal:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Occlusial_surface_enamel_of_tooth>",envir=prefixes)
assign("buccal:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Buccal_surface_enamel_of_tooth>",envir=prefixes)
assign("labial:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Labial_surface_enamel_of_tooth>",envir=prefixes)
assign("lingual:", "<http://purl.obolibrary.org/obo/FMA_no_fmaid_Lingual_surface_enamel_of_tooth>",envir=prefixes)
assign("is_dental_restoration_of:", "<http://purl.obolibrary.org/obo/OHD_0000091>",envir=prefixes)
assign("dental_restoration_material:", "<http://purl.obolibrary.org/obo/OHD_0000000>",envir=prefixes)
assign("has_specified_input:", "<http://purl.obolibrary.org/obo/OBI_0000293>",envir=prefixes)
assign("has_specified_output:", "<http://purl.obolibrary.org/obo/OBI_0000299>",envir=prefixes)
assign("asserted_type:", "<http://purl.obolibrary.org/obo/OHD_0000092>",envir=prefixes)
assign("tooth_number:", "<http://purl.obolibrary.org/obo/OHD_0000065>",envir=prefixes)
assign("female:", "<http://purl.obolibrary.org/obo/OHD_0000049>",envir=prefixes)
assign("male:", "<http://purl.obolibrary.org/obo/OHD_0000054>",envir=prefixes)
assign("patient:", "<http://purl.obolibrary.org/obo/OHD_0000012>",envir=prefixes)

all_prefixes_as_string <-  function ()
{
  paste(lapply(ls(prefixes),
              function(p) {paste("PREFIX ",p," ",get(p,prefixes),sep="")}),
       collapse ="\n")}
}

;; oh is this ever ugly, because I'm not versed in R data structures. Maybe I will fix it some time.

some_prefixes_as_string <- function (which,source="")
{
  paste(do.call(paste,append(cbind(lapply(as.list(which),
              function(p) {
                if(!(exists(p,prefixes))) stop("Didn't find prefix ",p,"used in:\n ", source);
                paste("PREFIX ",p," ",get(p,prefixes),sep="")})),alist(sep="\n"))),"\n")
}

prefixes_for_sparql <- function(query)
  { some_prefixes_as_string(as.list(cbind(regmatches(query,gregexpr("(\\S+:)", query,perl=TRUE))[[1]])),source=query) }
