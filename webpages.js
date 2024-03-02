var webPages = ["https://images.patolojiatlasi.com/acute-appendicitis/HE.html", "https://images.patolojiatlasi.com/myxoidliposarcoma/HE.html", "https://images.patolojiatlasi.com/amyloid/crystalviolet.html", "https://images.patolojiatlasi.com/congored/congored.html", "https://images.patolojiatlasi.com/ampullary-adenocarcinoma/HE.html", "https://images.patolojiatlasi.com/WDNET-ampulla/HE.html", "https://images.patolojiatlasi.com/helicobacterpylori/HE.html", "https://images.patolojiatlasi.com/helicobacterpylori/warthinstarry.html", "https://images.patolojiatlasi.com/helicobacterpylori/giemsa.html", "https://images.patolojiatlasi.com/helicobacterpylori/IHC.html", "https://images.patolojiatlasi.com/liver-hemangioma/HE.html", "https://images.patolojiatlasi.com/kidneyoncocytoma/HE.html", "https://images.patolojiatlasi.com/exostosis/oc.html", "https://images.patolojiatlasi.com/exostosis/oc001.html", "https://images.patolojiatlasi.com/exostosis/oc002.html", "https://images.patolojiatlasi.com/exostosis/HE.html", "https://images.patolojiatlasi.com/carcinogenesis/HE.html", "https://images.patolojiatlasi.com/reactive-atypia/HE.html", "https://images.patolojiatlasi.com/cervix-SCC/HE.html", "https://images.patolojiatlasi.com/chronicpyelonephritis/HE1.html", "https://images.patolojiatlasi.com/chronicpyelonephritis/HE2.html", "https://images.patolojiatlasi.com/chronic-pyelonephritis/HE.html", "https://images.patolojiatlasi.com/brain-arteriovenous-malformation/HE.html", "https://images.patolojiatlasi.com/colon-submucosal-lipoma/HE.html", "https://images.patolojiatlasi.com/mucinous-adenocarcinoma-colon/HE.html", "https://images.patolojiatlasi.com/colon-adenocarcinoma/HE.html", "https://images.patolojiatlasi.com/colon-adenocarcinoma/HE2.html", "https://images.patolojiatlasi.com/colon-adenocarcinoma/HE3.html", "https://images.patolojiatlasi.com/congestion-spleen/HE.html", "https://images.patolojiatlasi.com/crohn-colonoscopic-biopsy/all.html", "https://images.patolojiatlasi.com/crohn-colonoscopic-biopsy/HE1.html", "https://images.patolojiatlasi.com/crohn-colonoscopic-biopsy/HE2.html", "https://images.patolojiatlasi.com/crohn-colonoscopic-biopsy/HE3.html", "https://images.patolojiatlasi.com/crohn-colonoscopic-biopsy/HE4.html", "https://images.patolojiatlasi.com/celiac-disease/HE.html", "https://images.patolojiatlasi.com/cholesteatoma/cholesteatoma.html", "https://images.patolojiatlasi.com/cholesteatoma/HE.html", "https://images.patolojiatlasi.com/extramuralvenousinvasion/HE.html", "https://images.patolojiatlasi.com/extramuralvenousinvasion/HE2.html", "https://images.patolojiatlasi.com/extramural-venous-invasion/HE.html", "https://images.patolojiatlasi.com/endometriosis/HE.html", "https://images.patolojiatlasi.com/endometrial-polyp/HE.html", "https://images.patolojiatlasi.com/erosion/HE.html", "https://images.patolojiatlasi.com/granular-cell-tumor/HE.html", "https://images.patolojiatlasi.com/ochronosis/HE.html", "https://images.patolojiatlasi.com/pancreaticadenocarcinoma/case1-histopathology/viewer_z0.html", "https://images.patolojiatlasi.com/lecture1/Neoplazinin-Klinikopatolojik-Ozellikleri-ve-Epidemiyoloji.html", "https://images.patolojiatlasi.com/ectopic-adrenal/HE.html", "https://images.patolojiatlasi.com/candidaalbicans/cervicovaginalsmear/viewer_z0.html", "https://images.patolojiatlasi.com/brain-mucormycosis/HE.html", "https://images.patolojiatlasi.com/brain-mucormycosis/GMS.html", "https://images.patolojiatlasi.com/gallbladder-adenomyoma/HE.html", "https://images.patolojiatlasi.com/ischemia-gangrenous-cholecystitis/HE.html", "https://images.patolojiatlasi.com/lymphocytic-gastritis/all.html", "https://images.patolojiatlasi.com/lymphocytic-gastritis/HE.html", "https://images.patolojiatlasi.com/lymphocytic-gastritis/CD3.html", "https://images.patolojiatlasi.com/lymphocytic-gastritis/CD8.html", "https://images.patolojiatlasi.com/lymphocytic-gastritis/CD20.html", "https://images.patolojiatlasi.com/GBD1/HE.html", "https://images.patolojiatlasi.com/GBD2/HE.html", "https://images.patolojiatlasi.com/GBD/HE.html", "https://images.patolojiatlasi.com/GBD3/HE.html", "https://images.patolojiatlasi.com/high-grade-glioma-squash/HE.html", "https://images.patolojiatlasi.com/necrotisinggranuloma/HE.html", "https://images.patolojiatlasi.com/intrapancreaticspleen/HE.html", "https://images.patolojiatlasi.com/pituitary-adenoma/HE.html", "https://images.patolojiatlasi.com/hodgkin/HE.html", "https://images.patolojiatlasi.com/cholesterolpolyp/HE.html", "https://images.patolojiatlasi.com/glycogenstorage/HE.html", "https://images.patolojiatlasi.com/glycogenstorage/PAS.html", "https://images.patolojiatlasi.com/glycogenstorage/PASD.html", "https://images.patolojiatlasi.com/anthracosis/HE.html", "https://images.patolojiatlasi.com/anthracosis/HE2.html", "https://images.patolojiatlasi.com/melanosiscoli/HE.html", "https://images.patolojiatlasi.com/melanosiscoli/PAS.html", "https://images.patolojiatlasi.com/ICE1-WDNET-duodenum/HE.html", "https://images.patolojiatlasi.com/fat-necrosis/HE.html", "https://images.patolojiatlasi.com/hepatocellularcarcinoma/HCC/viewer_z0.html", "https://images.patolojiatlasi.com/fibrolamellar-hepatocellular-carcinoma/HE1.html", "https://images.patolojiatlasi.com/fibrolamellar-hepatocellular-carcinoma/HE2.html", "https://images.patolojiatlasi.com/fibrolamellar-hepatocellular-carcinoma/HE3.html", "https://images.patolojiatlasi.com/fibrolamellar-hepatocellular-carcinoma/HE4.html", "https://images.patolojiatlasi.com/pleomorphism/HE.html", "https://images.patolojiatlasi.com/brain-invasive-meningioma/HE.html", "https://images.patolojiatlasi.com/brain-invasive-meningioma}/HE.html", "https://images.patolojiatlasi.com/meningioma-bone-infiltration/HE.html", "https://images.patolojiatlasi.com/meningioma-bone-infiltration}/HE.html", "https://images.patolojiatlasi.com/abdominal-mesothelioma/HE.html", "https://images.patolojiatlasi.com/metaplasia/HE.html", "https://images.patolojiatlasi.com/metaplasia/HE_annotated.html", "https://images.patolojiatlasi.com/metaplasia/trypsin.html", "https://images.patolojiatlasi.com/metaplasia/HE_annotated3.html", "https://images.patolojiatlasi.com/metastaticsarcoma/HE.html", "https://images.patolojiatlasi.com/insidious-lymph-node-metastasis/HE.html", "https://images.patolojiatlasi.com/insidious-lymph-node-metastasis/OSKARCK.html", "https://images.patolojiatlasi.com/gastritis-cystica-profunda/HE.html", "https://images.patolojiatlasi.com/nasopharynx-nonkeratinizing-scc/HE.html", "https://images.patolojiatlasi.com/nasopharynx-nonkeratinizing-scc/panCK.html", "https://images.patolojiatlasi.com/nasopharynx-nonkeratinizing-scc/p63.html", "https://images.patolojiatlasi.com/nasopharynx-nonkeratinizing-scc/EBER.html", "https://images.patolojiatlasi.com/neuroendocrine-cytology/giemsa.html", "https://images.patolojiatlasi.com/enterobius-vermicularis/HE.html", "https://images.patolojiatlasi.com/PDAC-tru-cut/HE1.html", "https://images.patolojiatlasi.com/PDAC-tru-cut/HE2.html", "https://images.patolojiatlasi.com/PDAC-tru-cut/HE3.html", "https://images.patolojiatlasi.com/chorioamnionitis/HE.html", "https://images.patolojiatlasi.com/benign-prostate-hyperplasia/HE.html", "https://images.patolojiatlasi.com/fibrosis/HE.html", "https://images.patolojiatlasi.com/keloid-scar/HE.html", "https://images.patolojiatlasi.com/mammary-analogue-secretory-carcinoma/HE1.html", "https://images.patolojiatlasi.com/mammary-analogue-secretory-carcinoma/HE.html", "https://images.patolojiatlasi.com/mammary-analogue-secretory-carcinoma/HE2.html", "https://images.patolojiatlasi.com/mucin/mucicarmine.html", "https://images.patolojiatlasi.com/her2-cish/cish.html", "https://images.patolojiatlasi.com/tumor-spread/HE-cervix.html", "https://images.patolojiatlasi.com/tumor-spread/HE-endometrium.html", "https://images.patolojiatlasi.com/tumor-spread/HE-over.html", "https://images.patolojiatlasi.com/tumor-spread/HE-small-intestine.html", "https://images.patolojiatlasi.com/venous-invasion/HE.html", "https://images.patolojiatlasi.com/HSV/herpesesophagitis/viewer_z0.html", "https://images.patolojiatlasi.com/molluscum-contagiosum/HE.html"];
