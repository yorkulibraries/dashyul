#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"

ARGF.each do |line|
  line_array = line.parse_csv
  host = line_array[2]

  ### All of these are forbidden

  # Easily ignorable, trackers, etc.
  next if /ratingwidget.services.bmj.com/            =~ host
  next if /phpadsnew/                                =~ host # eg phpadsnew.cup.cam.ac.uk
  next if /oas.*/                                    =~ host
  next if /^ads\./                                   =~ host
  next if /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/       =~ host # Also catches 500.500.500.500, but who cares
  next if /amazonaws.com/                            =~ host
  next if /geoplugin.net/                            =~ host

  # Google
  next if /google.c(a|om)$/                          =~ host
  next if /google.com\.\w*$/                         =~ host
  next if /googleapis.com$/                          =~ host
  next if /google-analytics.com$/                    =~ host
  next if /youtube.com/                              =~ host
  next if /google.co.il$/                            =~ host
  next if /google.co.in$/                            =~ host
  next if /google.co.jp$/                            =~ host
  next if /^google.*edu$/                            =~ host
  next if /^google.*ac\.uk$/                         =~ host

  # Scholars Portal
  # Remember there are some very important scholarsportal.info domains!!!
  next if /^scholarsportal.info/                     =~ host
  next if /analytics.scholarsportal.info/              =~ host
  next if /answers.scholarsportal.info/              =~ host
  next if /brock.scholarsportal.info/                =~ host
  next if /dataverse.scholarsportal.info/            =~ host
  next if /drupal.scholarsportal.info/               =~ host
  next if /guelph.scholarsportal.info/               =~ host
  next if /guides.scholarsportal.info/               =~ host
  next if /images.scholarsportal.info/               =~ host
  next if /import.scholarsportal.info/               =~ host
  next if /laurier.scholarsportal.info/              =~ host
  next if /my.scholarsportal.info/                   =~ host
  next if /newsearch.scholarsportal.info/            =~ host
  next if /ocul.scholarsportal.info/                 =~ host
  next if /ozone.scholarsportal.info/                =~ host
  next if /queens.scholarsportal.info/               =~ host
  next if /racer.*scholarsportal.info/               =~ host
  next if /racer.scholarsportal.info/                =~ host
  next if /refworks.scholarsportal.info/             =~ host
  next if /request.scholarsportal.info/              =~ host
  next if /resolver.scholarsportal.info/             =~ host
  next if /rss.scholarsportal.info/                  =~ host
  next if /rwapp.scholarsportal.info/                =~ host
  next if /rwname.scholarsportal.info/               =~ host
  next if /ryerson.scholarsportal.info/              =~ host
  next if /search..scholarsportal.info/              =~ host
  next if /sfx.scholarsportal.info/                  =~ host
  next if /shib.*scholarsportal.info/                =~ host
  next if /spotdocs.scholarsportal.info/             =~ host
  next if /york.scholarsportal.info/                 =~ host
  next if /ocul.on.ca/                               =~ host

  # York
  next if /\.yorku.ca$/                              =~ host

  next if /^piwik\./                                 =~ host
  next if /^shibboleth/                              =~ host
  next if /^libproxy/                                =~ host
  next if /^ezproxy/                                 =~ host
  next if /^proxy/                                   =~ host
  next if /^dspace/                                  =~ host
  next if /^digitalcommons/                          =~ host
  next if /^drupal/                                  =~ host

  # Universities
  next if /wlu.ca$/                                  =~ host
  next if /uwindsor.ca/                              =~ host
  next if /\.crl.edu/                                =~ host
  next if /google-proxy.mit.edu/                     =~ host
  next if /uwo.ca$/                                  =~ host
  next if /wku.edu$/                                 =~ host
  next if /utoronto.ca$/                             =~ host
  next if /digitalcommons.kent.edu/                  =~ host
  next if /cdn.ncsu.edu/                             =~ host
  next if /dc.lib.unc.edu/                           =~ host
  next if /dc.msvu.ca/                               =~ host
  next if /dc.uwm.edu/                               =~ host
  next if /mtbi.asu.edu/                             =~ host
  next if /scholarsbank.uoregon.edu/                 =~ host
  next if /arrow.monash.edu.au/                      =~ host
  next if /www.nctr.usf.udu/                         =~ host
  next if /ulir.ul.ie/                               =~ host
  next if /unsw.edu.au/                              =~ host
  next if /lib.harvard.edu/                          =~ host
  next if /lib.ugent.be/                             =~ host
  next if /quod.lib.umich.edu/                       =~ host
  next if /name.umdl.umich.edu/                      =~ host
  next if /ecu.edu.au$/                              =~ host
  next if /ecu.edu$/                                 =~ host
  next if /ccdc.cam.ac.uk/                           =~ host
  next if /columbia.edu/                             =~ host
  next if /digitalcommons.wayne.edu/                 =~ host
  next if /cdlib.org$/                               =~ host
  next if /slac.stanford.edu/                        =~ host
  next if /mcmaster.ca/                              =~ host
  next if /mitpress.mit.edu/                         =~ host
  next if /subzero.lib.uoguelph.ca/                  =~ host
  next if /sfu.ca$/                                  =~ host
  next if /uni-duesseldorf.de/                       =~ host
  next if /repository.*\.edu/                        =~ host
  next if /respoitory.*\.ac\./                       =~ host
  next if /www.lib.*\.edu$/                          =~ host
  next if /collections.stanford.edu/                 =~ host
  next if /uwspace.uwaterloo.ca/                     =~ host
  next if /dlc.dlib.indiana.edu/                     =~ host
  next if /^sfx\./                                   =~ host
  next if /^eprints\./                               =~ host
  next if /^scholarship\./                           =~ host # Law school repositories
  next if /^scholarworks\./                          =~ host
  next if /^scholar\./                               =~ host
  next if /papyrus.bib.umontreal.ca/                 =~ host
  next if /digitalcommons.unl.edu/                   =~ host
  next if /repository.up.ac.za/                      =~ host

  # Open data and access
  next if /europepmc.org/                            =~ host
  next if /aof.revues.org/                           =~ host
  next if /.*mdpi.com/                               =~ host
  next if /\.plos.org$/                              =~ host
  next if /plosone.org$/                             =~ host
  next if /plosgenetics.org$/                        =~ host
  next if /ploscompbiol.org$/                        =~ host
  next if /plosntds.org$/                            =~ host
  next if /plosjournals.org$/                        =~ host
  next if /plospathogens.org$/                       =~ host
  next if /oops.theoptia.com$/                       =~ host
  next if /oops.uwaterloo.ca$/                       =~ host
  next if /rdatoolkit.org/                           =~ host
  next if /doaj.org/                                 =~ host
  next if /thecanadianencyclopedia.com/              =~ host
  next if /hathitrust.org/                           =~ host
  next if /hindawi.com/                              =~ host
  next if /jbioleng.org/                             =~ host
  next if /\.ispub.com$/                             =~ host
  next if /jneuroengrehab.com/                       =~ host
  next if /nureinvestigacion.es/                     =~ host
  next if /scoliosisjournal.com/                     =~ host
  next if /biomedcentral.com$/                       =~ host
  next if /\.smw.ch$/                                =~ host
  next if /uir.unisa.ac.za/                          =~ host
  next if /adsabs.harvard.edu/                       =~ host
  next if /adswww.harvard.edu/                       =~ host
  next if /plato.stanford.edu$/                      =~ host
  next if /19thc-artworldwide.org$/                  =~ host
  next if /statistiques.cleo.cnrs.fr$/               =~ host
  next if /sabinet.co.za$/                           =~ host
  next if /omicsonline.(com|org)$/                   =~ host
  next if /bnf.fr$/                                  =~ host
  next if /arctic.ucalgary.ca/                       =~ host
  next if /eurosurveillance.org/                     =~ host
  next if /imf.org$/                                 =~ host
  next if /genderwork.ca/                            =~ host
  next if /rrh.org.au/                               =~ host
  next if /behavioralandbrainfunctions.com/          =~ host
  next if /globalizationandhealth.com/               =~ host
  next if /dash.harvard.edu/                         =~ host
  next if /kcsnet.or.kr/                             =~ host
  next if /wormbase.org$/                            =~ host
  next if /oregonpdf.org/                            =~ host
  next if /www.nctr.usf.edu/                         =~ host
  next if /scholarcommons.usf.edu/                   =~ host
  next if /journals.lib.unb.ca/                      =~ host
  next if /www.cfa.harvard.edu/                      =~ host
  next if /frontiersin.org$/                         =~ host

  # Misc
  next if /appdynamics.com$/                         =~ host
  next if /noodletools.com$/                         =~ host
  next if /scholarlyiq.com$/                         =~ host # tracker
  next if /fdslive.oup.com$/                         =~ host # CDN
  next if /cloudfront.net$/                          =~ host # CDN
  next if /silverchair-cdn.com$/                     =~ host # CDN
  next if /silverchair.com$/                         =~ host # publishing platform
  next if /readspeaker.com$/                         =~ host
  next if /support.ebsco.com$/                       =~ host
  next if /literatumonline.com$/                     =~ host # publishing platform
  next if /crossref.org$/                            =~ host
  next if /doi.org$/                                 =~ host
  next if /refworks.com/                             =~ host
  next if /worldcat.org/                             =~ host
  next if /.*\.oclc.org/                             =~ host
  next if /swetswise.com/                            =~ host
  next if /catalog.hathitrust.org/                   =~ host
  next if /gc.ca$/                                   =~ host
  next if /purl.org/                                 =~ host
  next if /myendnoteweb.com/                         =~ host
  next if /archive.org$/                             =~ host
  next if /news.com.au/                              =~ host
  next if /glblgeopolitics.wordpress.com/            =~ host
  next if /wizfolio.com/                             =~ host
  next if /torontopubliclibrary.ca/                  =~ host
  next if /\.wordpress.com$/                         =~ host
  next if /\.yahoo.com$/                             =~ host
  next if /archivists.ca$/                           =~ host
  next if /newswire.ca$/                             =~ host
  next if /iareporter.com$/                          =~ host
  next if /imaginecanada.ca/                         =~ host
  next if /iassistdata.org/                          =~ host
  next if /\.ala.org$/                               =~ host
  next if /cba.org/                                  =~ host
  next if /unesco.org$/                              =~ host
  next if /who.int$/                                 =~ host
  next if /handle.net$/                              =~ host
  next if /toronto.ca$/                              =~ host
  next if /signon.thomsonreuters.com/                =~ host
  next if /www.jci.org/                              =~ host
  next if /www.inthefirstperson.com/                 =~ host
  next if /deepblue.lib.umich.edu/                   =~ host
  next if /umich.edu/                                =~ host
  next if /pkp.sfu.ca/                               =~ host
  next if /www.lights.ca/                            =~ host
  next if /www.trialsjournal.com/                    =~ host
  next if /digitalcommons.mcmaster.ca/               =~ host
  next if /www.scialert.net/                         =~ host
  next if /openx.aosis.co.za/                        =~ host
  next if /newsroom.opencolleges.edu.au/             =~ host
  next if /www.wjgnet.com/                           =~ host
  next if /www.opencolleges.edu.au/                  =~ host
  next if /www.teslcanadajournal.ca/                 =~ host
  next if /hv.conquestsystems.com/                   =~ host
  next if /contentmanager.copernicus.org/            =~ host
  next if /sala.clacso.edu.ar/                       =~ host
  next if /lib-openx.lib.sfu.ca/                     =~ host
  next if /evaluationcanada.ca/                      =~ host
  next if /www.bioline.org.br/                       =~ host
  next if /eol.org/                                  =~ host
  next if /www.implementationscience.com/            =~ host
  next if /www.dovepress.com/                        =~ host
  next if /dma.iriseducation.org/                    =~ host
  next if /www.radicalphilosophy.com/                =~ host
  next if /bloodjournal.hematologylibrary.org/       =~ host
  next if /www.scirp.org/                            =~ host
  next if /www.journalarchive.jst.go.jp/             =~ host
  next if /www.int-res.com/                          =~ host
  next if /dialnet.unirioja.es/                      =~ host
  next if /www.iovs.org/                             =~ host
  next if /www.journalofvision.org/                  =~ host
  next if /encompass.library.cornell.edu/            =~ host
  next if /journals.hil.unb.ca/                      =~ host
  next if /ethos.bl.uk/                              =~ host
  next if /digital.library.mcgill.ca/                =~ host
  next if /www.naric.com/                            =~ host
  next if /docs.lib.purdue.edu/                      =~ host
  next if /www.canadian-nurse.com/                   =~ host
  next if /www3.csj.ualberta.ca/                     =~ host
  next if /circle.ubc.ca/                            =~ host
  next if /biblio.caij.qc.ca/                        =~ host
  next if /digitool.library.mcgill.ca/               =~ host
  next if /www.jabfm.org/                            =~ host
  next if /www.jstage.jst.go.jp/                     =~ host
  next if /www.icpsr.umich.edu/                      =~ host
  next if /journals.tums.ac.ir/                      =~ host
  next if /dukeupress.edu$/                          =~ host
  next if /www.racgp.org.au/                         =~ host
  next if /www.biographi.ca/                         =~ host
  next if /ro.uow.edu.au/                            =~ host
  next if /vc.bridgew.edu/                           =~ host
  next if /proxy-check.library.cornell.edu/          =~ host
  next if /www.capmh.com/                            =~ host
  next if /sites.agu.org/                            =~ host
  next if /www.routledge.com/                        =~ host
  next if /pubmedcentralcanada.ca/                   =~ host
  next if /direct.bl.uk/                             =~ host
  next if /www.who.int/                              =~ host
  next if /(images|search).serialssolutions.com/     =~ host
  next if /www?.brandonu.ca/                         =~ host
  next if /proxy.library.cornell.edu/                =~ host
  next if /\.un.org/                                 =~ host
  next if /openlibrary.org/                          =~ host
  next if /www.bl.uk/                                =~ host
  next if /www.mcgill.ca/                            =~ host
  next if /library.brown.edu/                        =~ host
  next if /secure.toronto.ca/                        =~ host
  next if /web\d.login.cornell.edu/                  =~ host
  next if /usito.com$/                               =~ host
  next if /wsj.com$/                                 =~ host
  next if /wsj.net$/                                 =~ host
  next if /uiowa.edu$/                               =~ host
  next if /dowjones.com$/                            =~ host
  next if /cma.ca$/                                  =~ host
  next if /h-net.org$/                               =~ host
  next if /www.h-net.msu.edu/                        =~ host
  next if /victorianperiodicals.com/                 =~ host
  next if /homelesshub.ca/                           =~ host
  next if /usatoday.com/                             =~ host
  next if /blogspot.com$/                            =~ host
  next if /wordpress.com$/                           =~ host
  next if /diabetes.ca$/                             =~ host
  next if /cern.ch$/                                 =~ host
  next if /cato.org$/                                =~ host
  next if /logwebstats.qut.edu.au/                   =~ host
  next if /(assets|dtd|static).cambridge.org/        =~ host
  next if /(cookie|global|urchin).oup.com$/          =~ host
  next if /oi-underbar.oup.com/                      =~ host
  next if /cdn.cengage.com/                          =~ host
  next if /hsrc.ac.za/                               =~ host

  # OA journals
  next if /pimatisiwin.com$/                         =~ host
  next if /dsq-sds.org$/                             =~ host
  next if /\.jceps.com$/                             =~ host
  next if /jwildlifedis.org$/                        =~ host
  next if /ccjm.org$/                                =~ host
  next if /nursingtimes.net/                         =~ host
  next if /internationaljournalofcaringsciences.org/ =~ host
  next if /www.annals-general-psychiatry.com/        =~ host
  next if /ejournals.library.ualberta.ca/            =~ host
  next if /cjnr.archive.mcgill.ca/                   =~ host
  next if /academicjournals.org/                     =~ host
  next if /ojs.unbc.ca/                              =~ host
  next if /jatit.org/                                =~ host

  # Journals and associations we don't subscribe to
  # next if /thepsychologist.bps.org.uk/               =~ host
  # next if /jaoa.org$/                                =~ host

  # Government, NGO, UN
  next if /\.gov$/                                   =~ host
  next if /\.mil$/                                   =~ host
  next if /\.gov.on.ca/                              =~ host
  next if /statcan.ca/                               =~ host
  next if /\.gov\.\w*$/                              =~ host
  next if /ccohs.ca/                                 =~ host
  next if /csiro.au$/                                =~ host
  next if /europa.eu$/                               =~ host
  next if /\.nrc.ca/                                 =~ host
  next if /worldbank.org$/                           =~ host
  next if /stats.oecd.org/                           =~ host
  next if /banq.qc.ca$/                              =~ host
  next if /\.oecd.org$/                              =~ host

  # Now, the real work.
  platform = case
             # when /jpsj.ipap.jp$/.match(host)                          then '?'
             # when /www.investigacion-psicopedagogica.org$/.match(host) then '?'
             when /poolesplus.odyssi.com$/.match(host)                 then "19th Century Masterfile"
             when /aom.org$/.match(host)                               then "Academy of Management"
             when /accessengineeringlibrary.com$/.match(host)          then "AccessEngineering"
             when /www.accessible.com$/.match(host)                    then "Accessible Archives"
             when /humanitiesebook.org/.match(host)                    then "ACLS Humanities E-Book"
             when /asa.scitation.org/.match(host)                      then "Acoustical Society of America"
             when /akademiai.com$/.match(host)                         then "Akadémiai Kiadó"
             when /acm.org$/.match(host)                               then "Assoc Computing Machinery"
             when /acs.org$/.match(host)                               then "Amer Chem Soc"
             when /acponline.org$/.match(host)                         then "Amer Coll Physicians"
             when /ams.org$/.match(host)                               then "Amer Math Soc"
             when /amdigital.co.uk$/.match(host)                       then "Adam Matthew"
             when /alexanderstreet.com$/.match(host)                   then "Alexander Street"
             when /alexanderstreet2.com$/.match(host)                  then "Alexander Street"
             when /aspresolver.com$/.match(host)                       then "Alexander Street"
             when /academicvideostore.com$/.match(host)                then "Alexander Street"
             when /allenpress.com$/.match(host)                        then "Allen Press"
             when /aappublications.org$/.match(host)                   then "Amer Acad Pediatrics"
             when /aacrjournals.org$/.match(host)                      then "Amer Assoc Cancer Research"
             when /www.clinchem.org$/.match(host)                      then "Amer Assoc Clinical Chem"
             when /aacnjournals.org$/.match(host)                      then "Amer Assoc Critical Care Nurses"
             when /aafp.org$/.match(host)                              then "Amer Assoc Family Physicians"
             when /www.jimmunol.org$/.match(host)                      then "Amer Assoc Immunologists"
             when /aaiddjournals.org$/.match(host)                     then "Amer Assoc Int Dev Disabilities"
             when /jacn.org$/.match(host)                              then "Amer College Nutrition"
             when /diabetesjournals.org$/.match(host)                  then "Amer Diabetes Assoc Journals"
             when /aeaweb.org$/.match(host)                            then "Amer Econ Assoc"
             when /\.agu.org$/.match(host)                             then "Amer Geophysical Union"
             when /ahajournals.org$/.match(host)                       then "Amer Heart Assoc Journals"
             when /aiaa.org$/.match(host)                              then "Amer Inst Aeronatics"
             when /aimsciences.org$/.match(host)                       then "Amer Inst Mathematical Sciences"
             when /aip.org$/.match(host)                               then "Amer Inst Physics"
             when /physicstoday.org$/.match(host)                      then "Amer Inst Physics"
             when /\.aapt.org$/.match(host)                            then "Amer Inst Physics"
             when /asadl.org$/.match(host)                             then "Amer Inst Physics"
             when /aip.scitation.org$/.match(host)                     then "Amer Inst Physics"
             when /amjbot.org$/.match(host)                            then "Amer J Botany"
             when /ajnr.org$/.match(host)                              then "Amer J Neuroradiology"
             when /\.ajronline.org$/.match(host)                       then "Amer J Roentgenology"
             when /ametsoc.org$/.match(host)                           then "Amer Meteorological Soc"
             when /\.anb.org$/.match(host)                             then "Amer Nat Biography"
             when /nursingworld.org$/.match(host)                      then "Amer Nurses Assoc"
             when /aota.org$/.match(host)                              then "Amer Occupational Therapy Assoc"
             when /\.aps.org$/.match(host)                             then "Amer Physical Soc"
             when /physiology.org$/.match(host)                        then "Amer Physiological Soc"
             when /the-aps.org$/.match(host)                           then "Amer Physiological Soc"
             when /apsnet.org$/.match(host)                            then "Amer Phytopathological Soc"
             when /aphapublications.org$/.match(host)                  then "Amer Public Health Assoc"
             when /ascelibrary.org$/.match(host)                       then "Amer Soc Civil Engineering"
             when /jco.ascopubs.org$/.match(host)                      then "Amer Soc Clinical Oncology"
             when /ashspublications.org$/.match(host)                  then "Amer Soc Horticultural Sci"
             when /\.asm.org$/.match(host)                             then "Amer Soc Microbiology"
             when /asnjournals.org$/.match(host)                       then "Amer Soc Nephrology"
             when /nutrition.org$/.match(host)                         then "Amer Soc Nutrition"
             when /\.ajcn.org$/.match(host)                            then "Amer Soc Nutrition"
             when /aspetjournals.org$/.match(host)                     then "Amer Soc Pharmacology and Exper Therapeutics"
             when /www.plantcell.org$/.match(host)                     then "Amer Soc Plant Biol"
             when /www.ajtmh.org$/.match(host)                         then "Amer Soc Tropical Med and Hygiene"
             when /\.asha.org$/.match(host)                            then "Amer Speech-Language-Hearing Assoc"
             when /atsjournals.org$/.match(host)                       then "Amer Thoracic Js"
             when /www.amsciepub.com$/.match(host)                     then "Ammons Scientific"
             when /anatomy.tv$/.match(host)                            then "Anatomy..tv"
             when /www.annfammed.org$/.match(host)                     then "Annals Family Med"
             when /www.annals.org$/.match(host)                        then "Annals Internal Med"
             when /annee-philologique.com/.match(host)                 then "Année philologique"
             when /www.anthrosource.net/.match(host)                   then "AnthroSource"
             when /anthrosource.*.wiley.com/.match(host)               then "AnthroSource"
             when /atla(online)?.com$/.match(host)                     then "Amer Theological Lib Assn"
             when /^annals.org$/.match(host)                           then "Annals Internal Med"
             when /annualreviews.org$/.match(host)                     then "Annual Reviews"
             when /psycnet.apa.org/.match(host)                        then "APA: PsycNet"
             when /(content|my|doi).apa.org/.match(host)               then "APA: PsycNet"
             when /psyctherapy.apa.org/.match(host)                    then "APA: PsycTherapy"
             when /(static|www).apa.org/.match(host)                   then "APA"
             when /artstor.org/.match(host)                            then "Artstor"
             when /ascojournals.org/.match(host)                       then "ASCO Journals"
             when /\.arl.org$/.match(host)                             then "Assoc Research Libraries"
             when /atypon-link.com$/.match(host)                       then "Atypon"
             when /responsa.co.il/.match(host)                         then "Bar Ilan Responsa Project"
             when /begellhouse.com/.match(host)                        then "Begell House"
             when /bepress.com$/.match(host)                           then "bepress"
             when /berghahnjournals.com/.match(host)                   then "Berghahn Journals"
             when /journals.berghahnbooks.com/.match(host)             then "Berghahn Journals"
             when /biochemj.org$/.match(host)                          then "Biochemical J"
             when /bioone.org$/.match(host)                            then "BioOne"
             when /www.biolbull.org$/.match(host)                      then "Biological Bulletin"
             when /bna.birds.cornell.edu/.match(host)                  then "Birds of North America"
             when /sociologyencyclopedia.com/.match(host)              then "Blackwell Encyc of Soc"
             when /bloodjournal.org/.match(host)                       then "Blood J"
             when /\.bna.com$/.match(host)                             then "Bloomberg BNA"
             when /bloomsburydesignlibrary.com$/.match(host)           then "Bloomsbury Design Library"
             when /bmj.com$/.match(host)                               then "British Medical J"
             when /boneandjoint.org.uk/.match(host)                    then "Bone & Joint"
             when /books24x7.com$/.match(host)                         then "Books 24x7"
             when /booksinprint.com$/.match(host)                      then "Books in Print"
             when /brepolis.net$/.match(host)                          then "Brepolis"
             when /brill.(com|nl)$/.match(host)                        then "Brill"
             when /brillonline.(com|nl)$/.match(host)                  then "Brill Online"
             when /nijhoffonline.nl$/.match(host)                      then "Brill Online"
             when /bsc.chadwyck.com/.match(host)                       then "BSC (Chadwyck)"
             when /bvdep.com/.match(host)                              then "Bureau van Dijk"
             when /businessmonitor.com$/.match(host)                   then "Business Monitor"
             when /bmiresearch.com$/.match(host)                       then "Business Monitor"
             when /.*.cairn.info/.match(host)                          then "Cairn..info"
             when /cairn-int.info/.match(host)                         then "Cairn..info"
             when /cardonline.ca/.match(host)                          then "CARDOnline"
             when /ebooks.cambridge.org/.match(host)                   then "Cambridge Books Online"
             when /histories.cambridge.org/.match(host)                then "Cambridge Histories Online"
             when /journals.cambridge.org/.match(host)                 then "Cambridge Journals"
             when /celarc.ca/.match(host)                              then "desLibris"
             when /jnls.cup.org/.match(host)                           then "Cambridge Journals"
             when /www.cambridge.org/.match(host)                      then "Cambridge UP"
             when /canadalawbook.ca/.match(host)                       then "Canada Law Book"
             when /cacap-acpea.org/.match(host)                        then "Cdn Acad Child & Adolescent Psych"
             when /casw-acts.ca/.match(host)                           then "Cdn Assoc Social Workers"
             when /cbraonline.com/.match(host)                         then "Cdn Book Review Annual"
             when /ccl-lcj.ca/.match(host)                             then "Cdn Children's Literature"
             when /cdn-hr-reporter.ca$/.match(host)                    then "Cdn Human Rights Reporter"
             when /cif-ifc.org$/.match(host)                           then "Cdn Inst Forestry"
             when /cjc-online.ca/.match(host)                          then "Cdn J Communication"
             when /cjcmh.com/.match(host)                              then "Cdn J Community Mental Health"
             when /cmaj.ca$/.match(host)                               then "Cdn Med Assoc J"
             when /cpa-apc.org$/.match(host)                           then "Cdn Psychiatric Assn"
             when /eco.canadiana.ca/.match(host)                       then "Eco (Canadiana)"
             when /canadiana.ca$/.match(host)                          then "Canadiana"
             when /canadiana.org$/.match(host)                         then "Canadiana"
             when /canlii.org/.match(host)                             then "CanLII"
             when /cchonline.ca/.match(host)                           then "CCH"
             when /www.cell.com$/.match(host)                          then "Cell Press"
             when /www.ceeol.com/.match(host)                          then "Central & Eastern Euro Online Lib"
             when /afi.chadwyck.com/.match(host)                       then "Chadwyck: AFI"
             when /c19index.chadwyck.com/.match(host)                  then "Chadwyck: C19 Index"
             when /collections.chadwyck.com/.match(host)               then "Chadwyck: Chadwyck-Healey Lit Coll"
             when /eebo.chadwyck.com/.match(host)                      then "Chadwyck: EEBO"
             when /fiaf.chadwyck.com/.match(host)                      then "Chadwyck: FIAF"
             when /film.chadwyck.com/.match(host)                      then "Chadwyck: Film Index"
             when /fii.chadwyck.com/.match(host)                       then "Chadwyck: Film Index Intl"
             when /gerritsen.chadwyck.com/.match(host)                 then "Chadwyck: Gerritsen"
             when /parlipapers.chadwyck.com/.match(host)               then "Chadwyck: HCPP"
             when /iibp.chadwyck.com/.match(host)                      then "Chadwyck: Intl Index Black Per"
             when /iipaft.chadwyck.com/.match(host)                    then "Chadwyck: IIPAFT"
             when /chadwyck.com$/.match(host)                          then "Chadwyck: bucket" # Many more things in here
             when /chass.utoronto.ca/.match(host)                      then "CHASS Data Centre"
             when /chemnetbase.com/.match(host)                        then "ChemNetBase"
             when /chemspider.com/.match(host)                         then "ChemSpider"
             when /chemport.cas.org/.match(host)                       then "Chem Abstracts: Chemport"
             when /scifinder.cas.org/.match(host)                      then "Chem Abstracts: SciFinder"
             when /\.cas.org/.match(host)                              then "Chem Abstracts"
             when /chicagomanualofstyle.org/.match(host)               then "Chicago Manual of Style"
             when /cnki.com.cn/.match(host)                            then "China National Knowledge Infrastructure"
             when /nii.ac.jp/.match(host)                              then "CiNii"
             when /circ.greyhouse.ca/.match(host)                      then "CIRC (Greyhouse)"
             when /citeseerx.ist.psu.edu/.match(host)                  then "CiteSeerX"
             when /clarivate.com/.match(host)                          then "Clarivate Analytics"
             when /projectne.thomsonreuters.com/.match(host)           then "Clarivate Analytics"
             when /clinicalkey.com$/.match(host)                       then "ClinicalKey"
             when /cshlp.org$/.match(host)                             then "Cold Spring Harbor Lab Pr"
             when /genesdev.org$/.match(host)                          then "Cold Spring Harbor Lab Pr"
             when /ciaonet.org$/.match(host)                           then "Columbia International Affairs Online"
             when /cseweb.org.uk$/.match(host)                         then "Conf Socialist Economics"
             when /bcin.ca$/.match(host)                               then "Conservation Bibliography"
             when /\.biologists.org$/.match(host)                      then "Company of Biologists"
             when /cqpress.com$/.match(host)                           then "CQ Press"
             when /cqpress.gvpi.net$/.match(host)                      then "CQ Press"
             when /crcnetbase.com$/.match(host)                        then "CRCnetBASE"
             when /hbcponline.com/.match(host)                         then "CRC Handbook of Chemistry and Physics"
             when /criterionpic.com$/.match(host)                      then "Criterion Pictures"
             when /criterionondemand.com$/.match(host)                 then "Criterion Pictures"
             when /\.csa.ca$/.match(host)                              then "CSA Group"
             when /statindex.org$/.match(host)                         then "Current Index to Statistics"
             when /curio.ca$/.match(host)                              then "Curio..ca"
             when /datamonitor.com/.match(host)                        then "Data Monitor"
             when /dbpia.co.kr$/.match(host)                           then "DBpia (Korean)"
             when /degruyter.com$/.match(host)                         then "De Gruyter"
             when /doiserbia.nb.rs$/.match(host)                       then "doiSerbia"
             when /dramonlinelibrary.com$/.match(host)                 then "Drama Online"
             when /dukejournals.org$/.match(host)                      then "Duke Journals"
             when /eblib.com$/.match(host)                             then "Ebook Library"
             when /ebrary.com$/.match(host)                            then "Ebrary"
             when /ebsco.com$/.match(host)                             then "EbscoHost"
             when /ebsco.zone$/.match(host)                            then "EbscoHost"
             when /ebscohost.com$/.match(host)                         then "EbscoHost"
             when /epnet.com$/.match(host)                             then "EbscoHost"
             when /hwwilsonweb.com$/.match(host)                       then "EbscoHost"
             when /ecologyandsociety.org/.match(host)                  then "Ecology and Society"
             when /\.epw.in$/.match(host)                              then "Economic & Political Weekly"
             when /store.eiu.com/.match(host)                          then "Economist Intelligence Unit"
             when /www.euppublishing.com$/.match(host)                 then "Edinburgh University Press"
             when /educause.edu$/.match(host)                          then "Educause"
             when /elgaronline.com/.match(host)                        then "Edward Elgar"
             when /\.ecsdl.org$/.match(host)                           then "Electrochemical Society"
             when /e-enlightenment.com$/.match(host)                   then "Electronic Enlightenment"
             when /elsevier.com$/.match(host)                          then "Elsevier"
             when /els-cdn.com$/.match(host)                           then "Elsevier"
             when /elsevierhealth.com$/.match(host)                    then "Elsevier Health"
             when /embassynews.ca$/.match(host)                        then "Embassy News"
             when /emerald.com$/.match(host)                           then "Emerald Insight"
             when /emeraldinsight.com$/.match(host)                    then "Emerald Insight"
             when /emerald-library.com$/.match(host)                   then "Emerald Insight"
             when /\.eb.com$/.match(host)                              then "Encyc Britannica"
             when /.*.britannica.com/.match(host)                      then "Encyc Britannica"
             when /endojournals.org/.match(host)                       then "Endocrine Soc"
             when /endocrine.org/.match(host)                          then "Endocrine Soc"
             when /englishhistoricaldocuments.com/.match(host)         then "English Historical Documents"
             when /eric.ed.gov/.match(host)                            then "ERIC"
             when /.*.erudit.org/.match(host)                          then "Érudit"
             when /.*.eureka.cc/.match(host)                           then "Eureka..cc"
             when /euromonitor.com$/.match(host)                       then "Euromonitor"
             when /europaworld.com$/.match(host)                       then "Europa World Plus"
             when /www.eje-online.org$/.match(host)                    then "European J Endocrinology"
             when /erj.ersjournals.com$/.match(host)                   then "European Respiratory Soc"
             when /.*.engineeringvillage.com/.match(host)              then "Engineering Village"
             when /equinoxpub.com$/.match(host)                        then "Equinox Online"
             when /factiva.com$/.match(host)                           then "Factiva"
             when /familiesinsociety.org$/.match(host)                 then "Families in Society"
             when /www.fasebj.org$/.match(host)                        then "Fdn Amer Soc Experimental Biol"
             when /\.fas.org$/.match(host)                             then "Fdn Amer Scientists"
             when /\.fass.org$/.match(host)                            then "Fdn Animal Science Societies"
             when /fitne.net$/.match(host)                             then "Fitne" # Do we subscribe?
             when /filmplatform.net$/.match(host)                      then "Film Platform"
             when /digital.films.com/.match(host)                      then "Films on Demand"
             when /fod\.infobase\.com/.match(host)                     then "Films on Demand"
             when /foreignpolicy.com/.match(host)                      then "Foreign Policy"
             when /fulcrum.org$/.match(host)                           then "Fulcrum"
             when /\.gale.com$/.match(host)                            then "Gale"
             when /\.galegroup.com$/.match(host)                       then "Gale"
             when /\.rdsinc.com$/.match(host)                          then "Gale"
             when /geoscienceworld.org$/.match(host)                   then "GeoScienceWorld"
             when /\.getty.edu$/.match(host)                           then "Getty"
             when /globalfinancialdata.com$/.match(host)               then "Global Financial Data"
             when /genetics.org$/.match(host)                          then "Genetics"
             when /gsapubs.org$/.match(host)                           then "Geological Soc Amer"
             when /grantconnect.ca$/.match(host)                       then "Grant Connect"
             when /guilfordjournals.com/.match(host)                   then "Guilford Periodicals"
             when /hepg.org/.match(host)                               then "Harvard Ed Pub Group"
             when /hepgjournals.org/.match(host)                       then "Harvard Ed Pub Group"
             when /heinonline.org$/.match(host)                        then "HeinOnline"
             when /heinonlinebackup.com/.match(host)                   then "HeinOnline"
             when /hilltimes.com/.match(host)                          then "Hill Times"
             when /hsus.cambridge.org/.match(host)                     then "Historical Statistics of US"
             when /hoovers.com$/.match(host)                           then "Hoovers"
             when /avention.com$/.match(host)                          then "Hoovers"
             when /onesource.com$/.match(host)                         then "Hoovers"
             when /hrcak.srce.hr$/.match(host)                         then "Hrčak"
             when /www.hugeog.com$/.match(host)                        then "Human Geography"
             when /ibfd.org$/.match(host)                              then "IBFD"
             when /humankinetics.com$/.match(host)                     then "Human Kinetics"
             when /ibisworld.ca$/.match(host)                          then "IbisWorld"
             when /ibisworld.com$/.match(host)                         then "IbisWorld"
             when /ibisworld.com.cn$/.match(host)                      then "IbisWorld"
             when /icevirtuallibrary.com$/.match(host)                 then "ICE Virtual Library"
             when /inderscienceonline.com/.match(host)                 then "Inderscience"
             when /ieee.org$/.match(host)                              then "IEEE"
             when /informit.com.au$/.match(host)                       then "Informit"
             when /digital-library.theiet.org$/.match(host)            then "Inst Engineering Tech Digital Library"
             when /ihsglobalinsight.com$/.match(host)                  then "IHS Global Insight"
             when /\.globalinsight.com$/.match(host)                   then "IHS Global Insight"
             when /worldmarketsanalysis.com$/.match(host)              then "IHS Global Insight"
             when /fpinfomart.ca$/.match(host)                         then "Infomart"
             when /elibrary.*imf.org/.match(host)                      then "IMF eLibrary"
             when /iclr.co.uk/.match(host)                             then "Inc Council Law Reporting"
             when /jcr.incites.thomsonreuters.com/.match(host)         then "InCites Journal Citation Reports"
             when /indexcopernicus.com/.match(host)                    then "Index Copernicus"
             when /ijpsonline.com/.match(host)                         then "Indian J Pharmaceutical Sci"
             when /www.indiastat.com$/.match(host)                     then "Indiastat"
             when /informs.org$/.match(host)                           then "Informs"
             when /ingentaconnect.com$/.match(host)                    then "IngentaConnect"
             when /ingenta.com$/.match(host)                           then "IngentaConnect"
             when /ingentaselect.com$/.match(host)                     then "IngentaConnect"
             when /www.catchword.com$/.match(host)                     then "IngentaConnect"
             when /intelliconnect.ca$/.match(host)                     then "IntelliConnect"
             when /investigacion-psicopedagogica.org/.match(host)      then "Investigación Psicopedagógica"
             when /iospress.(com|nl)$/.match(host)                     then "IOS Press"
             when /itergateway.org$/.match(host)                       then "Iter"
             when /nlx.com$/.match(host)                               then "InteLex"
             when /ipasource.com$/.match(host)                         then "IPA (Intl Phonetic Alphabet) Source"
             when /\.iop.org$/.match(host)                             then "Inst of Physics"
             when /iopscience.org$/.match(host)                        then "Inst of Physics"
             when /communicationencyclopedia.com$/.match(host)         then "Intl Encyc Communication"
             when /ijmhs.com$/.match(host)                             then "Intl J Mental Health Systems"
             when /iucr.org$/.match(host)                              then "Intl Union Crystallography"
             when /lordisco.com$/.match(host)                          then "Jazz Discography"
             when /jaapl.org$/.match(host)                             then "J Amer Acad Psych & Law"
             when /jbc.org$/.match(host)                               then "J Bio Chem"
             when /jhrsonline.org$/.match(host)                        then "J Human Reproductive Sciences"
             when /www.jlr.org$/.match(host)                           then "J Lipid Research"
             when /jmir.org$/.match(host)                              then "J Medical Internet Research"
             when /jneurosci.org/.match(host)                          then "J Neurosci"
             when /jwildlifedis.org/.match(host)                       then "J Wildlife Diseases"
             when /\.?jamanetwork.com/.match(host)                     then "JAMA Network"
             when /\.ama-assn.org$/.match(host)                        then "JAMA Network"
             when /jst.go.jp$/.match(host)                             then "Japanese Science & Technology Agency" # Do we subscribe to this?
             when /jbe-platform.com$/.match(host)                      then "John Benjamins"
             when /litguide.press.jhu.edu$/.match(host)                then "Johns Hopkins Guide to Lit Theory and Crit"
             when /jstor.org$/.match(host)                             then "JSTOR"
             when /caliber.ucpress.net/.match(host)                    then "JSTOR" # Moved recently
             when /justcite.com$/.match(host)                          then "JustCite"
             when /justis.com$/.match(host)                            then "Justis"
             when /kanopystreaming.com$/.match(host)                   then "Kanopy"
             when /kanopy.com$/.match(host)                            then "Kanopy"
             when /karger.com$/.match(host)                            then "Karger"
             when /keesings.com$/.match(host)                          then "Keesing's World News Archive"
             when /mergentkbr.com$/.match(host)                        then "Key Business Ratios"
             when /kluwerarbitration.com$/.match(host)                 then "Kluwer Arbitration"
             when /kluwerlawonline.com$/.match(host)                   then "Kluwer Law Online"
             when /.*knotia.ca/.match(host)                            then "Knotia"
             when /knovel.com$/.match(host)                            then "Knovel"
             when /krpia.co.kr$/.match(host)                           then "KRpia (Korean)"
             when /llmcdigital.org$/.match(host)                       then "Law Lib Microform Consortium"
             when /lawyersdaily.ca$/.match(host)                       then "Lawyer's Daily"
             when /www.lawyersweekly-digital.com$/.match(host)         then "Lawyers Weekly"
             when /www.editlib.org$/.match(host)                       then "LearnTechLib"
             when /lerobert.com/.match(host)                           then "Le Robert"
             when /lexisnexis.com$/.match(host)                        then "LexisNexis"
             when /lexis-nexis.com$/.match(host)                       then "LexisNexis"
             when /lexis.com$/.match(host)                             then "LexisNexis"
             when /nexisuni.com$/.match(host)                          then "LexisNexis"
             when /advance.lexis.com/.match(host)                      then "Lexis Advance Quicklaw"
             when /lexisadvancequicklaw.ca/.match(host)                then "Lexis Advance Quicklaw"
             when /lexissecuritiesmosaic.com/.match(host)              then "Lexis Securities Mosaic"
             when /liebertpub.com$/.match(host)                        then "Liebert"
             when /liverpooluniversitypress.co.uk/.match(host)         then "Liverpool U Press"
             when /llmc.com$/.match(host)                              then "LLMC Digital"
             when /loebclassics.com$/.match(host)                      then "Loeb Classics"
             when /.*.longwoods.com/.match(host)                       then "Longwoods"
             when /manupatra.*in$/.match(host)                         then "Manupatra"
             when /.*.marketline.com/.match(host)                      then "MarketLine"
             when /mcintyre.ca$/.match(host)                           then "McIntyre Media"
             when /mcnabbconnolly.ca/.match(host)                      then "McNabb Connolly"
             when /.*mdpi.org/.match(host)                             then "MDPI (org)"
             when /medscimonit.com$/.match(host)                       then "Med Sci Monitor"
             when /mergentonline.com/.match(host)                      then "Mergent"
             when /mergent.com/.match(host)                            then "Mergent"
             when /mergentarchives.com/.match(host)                    then "Mergent"
             when /mergenthorizon.com/.match(host)                     then "Mergent"
             when /mergentintellect.com/.match(host)                   then "Mergent Intellect"
             when /metapress.com/.match(host)                          then "Metapress"
             when /mgg-online.com/.match(host)                         then "MGG Online"
             when /sgmjournals.org$/.match(host)                       then "Micobiology Soc"
             when /cognet.mit.edu/.match(host)                         then "MIT Cognet"
             when /mitpressjournals.org/.match(host)                   then "MIT Press Journals"
             when /www.mlajournals.org$/.match(host)                   then "Modern Language Assoc"
             when /mcponline.org$/.match(host)                         then "Molecular & Cellular Proteomics"
             when /www.molbiolcell.org$/.match(host)                   then "Molecular Biol of the Cell"
             when /www.morganclaypool.com$/.match(host)                then "Morgan and Claypool"
             when /muse.jhu.edu$/.match(host)                          then "Muse"
             when /\.nap.edu$/.match(host)                             then "Natl Academies Pr"
             when /\.nber.org$/.match(host)                            then "Natl Bur Eco Research"
             when /\.ncte.org$/.match(host)                            then "Natl Coun Teachers English"
             when /\.nature.com$/.match(host)                          then "Nature"
             when /naxosmusiclibrary.com$/.match(host)                 then "Naxos Music"
             when /naxos.com$/.match(host)                             then "Naxos Music"
             when /netlibrary.com$/.match(host)                        then "NetLibrary"
             when /.*ncbi.nlm.nih.gov/.match(host)                     then "Nat Center Biotech Info"
             when /.*nejm.org/.match(host)                             then "New England J Med"
             when /newleftreview.org/.match(host)                      then "New Left Review"
             when /dictionaryofeconomics.com$/.match(host)             then "New Palgrave Dictionary of Economics"
             when /nybooks.com/.match(host)                            then "New York Review of Books"
             when /\.newsbank.com/.match(host)                         then "Newsbank"
             when /\.nfb.ca/.match(host)                               then "NFB"
             when /\.onf.ca/.match(host)                               then "NFB"
             when /nrcresearchpress.com$/.match(host)                  then "NRC Research Press"
             when /obriensforms.com$/.match(host)                      then "O'Brien's Encyc of Forms"
             when /www.oecd-?ilibrary.org/.match(host)                 then "OECD iLibrary"
             when /sourceoecd.org$/.match(host)                        then "OECD iLibrary"
             when /oecdobserver.org$/.match(host)                      then "OECD iLibrary"
             when /\.oed.com$/.match(host)                             then "OED"
             when /^oed.com$/.match(host)                              then "OED"
             when /ohiolink.edu$/.match(host)                          then "OhioLINK"
             when /theoncologist.alphamedpress.org$/.match(host)       then "Oncologist"
             when /ontheboards.tv$/.match(host)                        then "OntheBoards..tv"
             when /oeb.griffith.ox.ac.uk/.match(host)                  then "Online Egyptological Bib"
             when /openedition.org$/.match(host)                       then "OpenEdition"
             when /opticsinfobase.org/.match(host)                     then "Optical Society"
             when /\.osa.org/.match(host)                              then "Optical Society"
             when /osapublishing.org/.match(host)                      then "Optical Society"
             when /osa-opn.org/.match(host)                            then "Optics and Photonics"
             when /academic.oup.com/.match(host)                       then "Oxford Academic"
             when /oxfordartonline.com/.match(host)                    then "Oxford Art Online"
             when /oxfordbibliographies.com/.match(host)               then "Oxford Bibliographies"
             when /oxfordlanguagedictionaries.com/.match(host)         then "Oxford Dictionaries"
             when /oxforddictionaries.com/.match(host)                 then "Oxford Dictionaries"
             when /oxforddnb.com/.match(host)                          then "Oxford DNB"
             when /oxfordhandbooks.com/.match(host)                    then "Oxford Handbooks"
             when /www.oxfordislamicstudies.com$/.match(host)          then "Oxford Islamic Studies Online"
             when /ouplaw.com$/.match(host)                            then "Oxford Law"
             when /oxfordmusiconline.com/.match(host)                  then "Oxford Music Online"
             when /www.mpepil.com$/.match(host)                        then "Oxford Public International Law"
             when /oxfordreference.com/.match(host)                    then "Oxford Reference"
             when /oxford-climateweather2.com/.match(host)             then "Oxford Reference"
             when /encpopmusic4.com/.match(host)                       then "Oxford Reference"
             when /oxfordscholarship.com/.match(host)                  then "Oxford Scholarship"
             when /oxfordscholarlyeditions.com$/.match(host)           then "Oxford Scholarly Editions Online"
             when /oxfordwesternmusic.com/.match(host)                 then "Oxford Western Music"
             when /oxfordjournals.org$/.match(host)                    then "OUP Journals"
             when /\.ovid.com$/.match(host)                            then "Ovid"
             when /silverplatter.com$/.match(host)                     then "Ovid"
             when /palgrave-journals.com$/.match(host)                 then "Palgrave Macmillan Journals"
             when /paperofrecord.hypernet.ca/.match(host)              then "Paper of Record"
             when /paratext.com$/.match(host)                          then "Paratext"
             when /peeters-leuven.be$/.match(host)                     then "Peeters Online Journals"
             when /cambridgesoft.com$/.match(host)                     then "PerkinElmer"
             when /persee.fr$/.match(host)                             then "Persée"
             when /phcogrev.com$/.match(host)                          then "Pharmacognosy Rev"
             when /pdcnet.org$/.match(host)                            then "Philosophy Doc Ctr"
             when /philpapers.org$/.match(host)                        then "PhilPapers"
             when /envplan.com$/.match(host)                           then "Pion Journals"
             when /pkulaw.cn$/.match(host)                             then "Pkulaw..cn"
             when /plantphysiol.org$/.match(host)                      then "Plant Physiology"
             when /plunkettresearchonline.com$/.match(host)            then "Plunkett"
             when /pnas.org$/.match(host)                              then "Proc Nat Acad Sci"
             when /preqin.com$/.match(host)                            then "Preqin"
             when /pressreader.com/.match(host)                        then "PressReader"
             when /annals.math.princeton.edu/.match(host)              then "Princeton: Annals of Mathematics"
             when /privco.com$/.match(host)                            then "PrivCo"
             when /projecteuclid.org$/.match(host)                     then "Project Euclid"
             when /proquest.com$/.match(host)                          then "ProQuest"
             when /proquest.umi.com/.match(host)                       then "ProQuest"
             when /gradworks.umi.com/.match(host)                      then "ProQuest"
             when /lion.chadwyck.com/.match(host)                      then "ProQuest"
             when /pao.chadwyck.com/.match(host)                       then "ProQuest"
             when /\.csa.com/.match(host)                              then "ProQuest"
             when /pagesofthepast.ca/.match(host)                      then "ProQuest"
             when /myilibrary.com/.match(host)                         then "ProQuest: My iLibrary"
             when /safaribooksonline.com/.match(host)                  then "ProQuest: Safari Books Online"
             when /\.psychiatrist.com/.match(host)                     then "Psychiatrist..com"
             when /psychiatryonline.(com|org)$/.match(host)            then "PsychiatryOnline"
             when /pep-web.org$/.match(host)                           then "Psychoanalytic Electronic Pub"
             when /.*pubmedcentral.com/.match(host)                    then "PubMed Central"
             when /.*pubmedcentral.nih.gov/.match(host)                then "PubMed Central"
             when /rep.routledge.com/.match(host)                      then "Routledge Encyc of Phil"
             when /\.rsc.org/.match(host)                              then "Royal Soc Chem"
             when /\.reaxys.com/.match(host)                           then "Reaxys"
             when /\.redalyc.org/.match(host)                          then "Redalyc"
             when /redalyc.uaemex.mx/.match(host)                      then "Redalyc"
             when /libris.ca$/.match(host)                             then "Reference Press"
             when /repec.org$/.match(host)                             then "RePEc"
             when /repere.*sdm.qc.ca/.match(host)                      then "Repere"
             when /reproduction-online.org/.match(host)                then "Reproduction"
             when /revues.org$/.match(host)                            then "Revues..org"
             when /rocksbackpages.com/.match(host)                     then "Rock's Back Pages"
             when /rupress.org/.match(host)                            then "Rockefeller U Pr"
             when /royalsocietypublishing.org/.match(host)             then "Royal Society"
             when /rcpsych.org/.match(host)                            then "Royal College Psychiatrists"
             when /sagepub.com$/.match(host)                           then "Sage"
             when /sage-ereference.com$/.match(host)                   then "Sage"
             when /www.perceptionweb.com$/.match(host)                 then "Sage"
             when /rsmjournals.com$/.match(host)                       then "Sage"
             when /scconline.com$/.match(host)                         then "SCC Online"
             when /geo.*scholarsportal.info/.match(host)               then "Scholars GeoPortal"
             when /ebooks.*scholarsportal.info/.match(host)            then "Scholars Portal Books"
             when /books.*scholarsportal.info/.match(host)             then "Scholars Portal Books"
             when /ebookisis.*.scholarsportal.info/.match(host)        then "Scholars Portal Books"
             when /journals.*scholarsportal.info/.match(host)          then "Scholars Portal Journals"
             when /odesi.*scholarsportal.info/.match(host)             then "Scholars Portal <odesi>"
             when /.*odesi.ca/.match(host)                             then "Scholars Portal <odesi>"
             when /.*scielo.br/.match(host)                            then "SciELO"
             when /.*scielo.sa.cr/.match(host)                         then "SciELO"
             when /.*scielo.cl/.match(host)                            then "SciELO"
             when /.*scielo.org.*/.match(host)                         then "SciELO"
             when /.*scielo.edu/.match(host)                           then "SciELO"
             when /scielo.isciii.es/.match(host)                       then "SciELO"
             when /www.scielo.*.pt/.match(host)                        then "SciELO"
             when /scielo.unam.mx/.match(host)                         then "SciELO"
             when /www.scielosp.org/.match(host)                       then "SciELO Health"
             when /sciencemag.org$/.match(host)                        then "Science (AAAS)"
             when /scialert.net/.match(host)                           then "Science Alert"
             when /sciencedirect.com$/.match(host)                     then "ScienceDirect"
             when /\.scival.com/.match(host)                           then "SciVal"
             when /\.scopus.com/.match(host)                           then "Scopus"
             when /socialistregister.com/.match(host)                  then "Socialist Register"
             when /sfaajournals.net/.match(host)                       then "Soc Applied Anthropology"
             when /endocrinology-journals.org$/.match(host)            then "Soc Endocrinology"
             when /siam.org$/.match(host)                              then "Soc Industrial Applied Math"
             when /www.socresonline.org.uk/.match(host)                then "Sociological Research Online"
             when /simplymap.c(a|om)$/.match(host)                     then "Simply Analytics"
             when /simplyanalytics.com)$/.match(host)                  then "Simply Analytics"
             when /\.snl.com$/.match(host)                             then "SNL Financial"
             when /seg.org$/.match(host)                               then "Soc Exploration Geophysicists"
             when /www.biolreprod.org$/.match(host)                    then "Soc Study Reproduction"
             when /spiedigitallibrary.org$/.match(host)                then "SPIE Digital Lib"
             when /springer.com$/.match(host)                          then "Springer"
             when /springerlink.com$/.match(host)                      then "Springer"
             when /springernature.com$/.match(host)                    then "Springer"
             when /springerpub.com$/.match(host)                       then "Springer"
             when /palgraveconnect.com$/.match(host)                   then "Springer"
             when /adisonline.com$/.match(host)                        then "Springer"
             when /springerprotocols.com$/.match(host)                 then "Springer Protocols"
             when /standardandpoors.com$/.match(host)                  then "Standard & Poor's"
             when /statista.com$/.match(host)                          then "Statista"
             when /statcdn.com$/.match(host)                           then "Statista"
             when /sustainalytics.com$/.match(host)                    then "Sustainalytics"
             when /wwwords.co.uk$/.match(host)                         then "Symposium Books"
             when /taylorfrancis.com$/.match(host)                     then "T & F eBooks"
             when /taylorandfrancis.com$/.match(host)                  then "T & F eBooks"
             when /www.tandfebooks.com/.match(host)                    then "T & F eBooks"
             when /tandfonline.com$/.match(host)                       then "T & F Online"
             when /informahealthcare.com$/.match(host)                 then "T & F Online"
             when /informaworld.com$/.match(host)                      then "T & F Online"
             when /landesbioscience.com$/.match(host)                  then "T & F Online"
             when /leaonline.com$/.match(host)                         then "T & F Online"
             when /maneyonline.com$/.match(host)                       then "T & F Online"
             when /taxanalysts.com$/.match(host)                       then "Tax Analysts"
             when /tcrecord.org$/.match(host)                          then "Teachers College Record"
             when /telospress.com$/.match(host)                        then "Telos"
             when /(www|stephanus).tlg.uci.edu$/.match(host)           then "Thesauraus Linguae Graecae"
             when /thieme-connect.(com|de)$/.match(host)               then "Thieme"
             when /thomsonib.com$/.match(host)                         then "Thomson Research"
             when /thomsonreuters.com$/.match(host)                    then "Thomson Reuters"
             when /trb.org$/.match(host)                               then "Transportation Research Board"
             when /utopia.cs.man.ac.uk/.match(host)                    then "U Manchester: Utopia"
             when /artfl.*uchicago.edu/.match(host)                    then "U Chicago: ARTFL"
             when /press.uchicago.edu$/.match(host)                    then "U Chicago Pr"
             when /journals.uchicago.edu$/.match(host)                 then "U Chicago Pr"
             when /bmc.lib.umich.edu/.match(host)                      then "U Mich: Bib Asian Studies"
             when /hapi.ucla.edu/.match(host)                          then "UCLA: Hispanic American Periodicals Ind"
             when /uclajournals.org/.match(host)                       then "UCLA: Asian American Studies Center"
             when /utpjournals.press/.match(host)                      then "U Toronto Press"
             when /uwpress.org$/.match(host)                           then "U Wisconsin Press"
             when /ulrichsweb.serialssolutions.com/.match(host)        then "Ulrich's"
             when /ulrichsweb.com/.match(host)                         then "Ulrich's"
             when /universalis-edu.com/.match(host)                    then "Universalis"
             when /universitypressscholarship.com/.match(host)         then "University Press Scholarship"
             when /universitypublishingonline.org/.match(host)         then "University Pub Online"
             when /www.pmb.ca/.match(host)                             then "Vividata"
             when /kmrsoftware.net/.match(host)                        then "Vividata"
             when /vividata.ca/.match(host)                            then "Vividata"
             when /vlex.com/.match(host)                               then "vLex"
             when /wanfangdata.com$/.match(host)                       then "Wanfang Data"
             when /wanfangdata.com.cn$/.match(host)                    then "Wanfang Data"
             when /webofknowledge.com$/.match(host)                    then "Web of Science"
             when /webofscience.com$/.match(host)                      then "Web of Science"
             when /wrds.*wharton.upenn.edu$/.match(host)               then "Wharton Research Data Serv"
             when /westlaw.com$/.match(host)                           then "Westlaw"
             when /wiley.com$/.match(host)                             then "Wiley"
             when /blackwell-?synergy.com$/.match(host)                then "Wiley"
             when /blackwellreference.com$/.match(host)                then "Wiley"
             when /\.els.net$/.match(host)                             then "Wiley"
             when /esajournals.org$/.match(host)                       then "Wiley"
             when /www.jphysiol.org$/.match(host)                      then "Wiley"
             when /wol-prod-cdn.literatumonline.com$/.match(host)      then "Wiley"
             when /www.literatureencyclopedia.com$/.match(host)        then "Wiley-Blackwell Encyc Literature"
             when /www.psychosomaticmedicine.org$/.match(host)         then "Wolters Kluwer"
             when /anesthesia-analgesia.org$/.match(host)              then "Wolters Kluwer"
             when /\.lww.com$/.match(host)                             then "Wolters Kluwer"
             when /\.cch.com/.match(host)                              then "Wolters Kluwer"
             when /wolterskluwer.com/.match(host)                      then "Wolters Kluwer"
             when /wkhealth.com/.match(host)                           then "Wolters Kluwer"
             when /warc.com$/.match(host)                              then "World Advertising Research Ctr"
             when /worldscientific.com/.match(host)                    then "World Scientific"
             else
               host
             end
  puts [line_array[0], line_array[1], platform].to_csv
end
