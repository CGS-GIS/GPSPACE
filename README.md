*La version française suit.*

# GPSPACE software

## Introduction

The GPSPACE software was developed in the Fortran programming language and used operationally at the Canadian Geodetic Survey (CGS) from the 90's until August 2018. From 2003 the software was operating behind the scene of the CSRS-PPP on-line service offered by CGS. In August 2018, the GPSPACE was replaced with a newer package offering better maintainability and performance and CGS decided to cease the support of GPSPACE. Over the years a number of organizations and individuals have obtained limited licensed use of the source code. CGS therefore opted to release the software under the MIT License to the larger community.

CGS released GPSPACE by posting the software and related configuration files along with test cases results as an archived repository on github.com. As an archived repository, it is not possible to update its content and pull requests will fail, but it is still possible to fork and modify its content as per the Licence terms, if anyone or any group is interested. CGS has no intention to support the application in the future, either through updates to the source code, or by adding documentation or test cases.

## Precise Point Positioning

Precise Point Positioning is a processing methodology that combines Global Navigation Satellite Systems (GNSS) data collected on the ground, in air or in space, with precise GNSS satellite data products (positions and clock states) to generate positions of high precision. Factors such as the quality of GNSS data products, length of observation sessions, type of data collected, type of receiving hardware and conditions of collection will affect the quality of computed positions.

References :

 [1] Zumberge J, Heflin MB, Jefferson DC, et al. (1997) Precise point positioning for the efficient and robust analysis of GPS data for large networks. J. Geophys. Res. 102 (B3), 5005-5017, doi:10.1029/96JB03860.
 
 [2] Kouba J, and Héroux P (2001) Precise point positioning using IGS orbit and clock products. GPS Solutions 5 (2), 12-28, doi:10.1007/PL00012883.
 
## GPSPACE capabilities

The GPSPACE software was developed in view of achieving the highest geodetic precision possible. The version released here can:
 - process GPS, Glonass, Galileo and/or Beidou data,
 - process in static or kinematic modes,
 - process dual frequency data,
 - process single frequency data (pseudoranges-only or pseudoranges+phases),
 - perform backward smoothing of time-varying parameters (clock, tropospheric delay, kinematic positions),
 - perform sub-optimal GPS carrier-phase ambiguity fixing with appropriate satellite information.
 
The GPSPACE provides estimates for:
 - antenna/marker positions in static and kinematic modes,
 - constellation-specific receiver clock states,
 - tropospheric delay and EW and NS gradients as random-walk parameters,
 - carrier-phase ambiguities.
 
The GPSPACE accepts data in the following formats:
 - GNSS tracking data (RINEX 2.11),
 - GPS navigation data (RINEX 2.11, MRTCA, RTCM),
 - GNSS orbit and clocks (SP3d, RINEX-CLOCK),
 - GPS orbit and clock corrections to navigation (MRTCA and RTCM-SSR)
 - ionospheric TEC maps (IONEX, spherical harmonics, MRTCA, RTCM-SSR)
 - absolute antenna calibration models (ATX)
 - ocean loading parameters (HARPOS, BLQ)
 - tropospheric mapping models (VMF1, GPT2 5x5 grid)
 - pole coordinates (IGS erp)
 
## Coding style and documentation

GPSPACE is a legacy software for which parts of the source code date back to the 70's. Over the years of its creation and improvement, very little attention was given to maintaining any kind of coding standard. Additionally no documentation is provided, other than the usage examples provided in the test cases. The software has however gone through very extensive testing during its active years supporting the CSRS-PPP service.

Copyright (c) 2018 Government of Canada. Under MIT Licence terms


# Logiciel GPSPACE

## Introduction

Le logiciel GPSPACE a été développé en langage Fortran et utilisé opérationnellement aux Levés géodésiques du Canada (LGC) des années 90 à août 2018. Depuis 2003 le logiciel opérait en arrière-scène du service en-ligne CSRS-PPP offert par les LGC. En août 2018, GPSPACE a été remplacé par un nouveau logiciel plus aisé à maintenir et offrant de meilleures performances et les LGC ont décidé de cesser le support de GPSPACE. Au cours des années un certain nombre d'organisations et d'individus ont obtenu une Licence limitée d'utilisation du code source. Les LGC ont choisi de publier le logiciel sous License de type MIT.

Les LGC ont publié GPSPACE en déposant le code source et ses fichiers de configuration ainsi que les résultats de traitement de cas types en tant que répertoire archivé (archived repository) sur github.com. En tant que répertoire archivé, il n'est pas possible de le mettre à jour et les requêtes d'ajout (pull requests) échoueront, mais il est possible le copier (fork) et modifier selon les termes de la Licence, si quelqu'un ou quelque groupe est intéressé. À l'avenir, les LGC n'ont pas l'intention d'offrir quelque support que ce soit pour le logiciel, ni mise-à-jour du code source, ni ajout de documentation ou modification des cas types.

## Positionnement Ponctuel Précis

Le Positionnement ponctuel précis est une méthode de traitement combinant les données des Global Navigation Satellite Systems (GNSS) collectées au sol, dans les airs ou l'espace, avec des produits précis de satellites GNSS (positions et états d'horloge) pour générer des positions de haute précision. Des facteurs tels que la qualité des produits GNSS, la durée des sessions d'observations, le type de données collectées, et le type d'équipement de collecte vont affecter la qualité des positions calculées.

Références:

 [1] Zumberge J, Heflin MB, Jefferson DC, et al. (1997) Precise point positioning for the efficient and robust analysis of GPS data for large networks. J. Geophys. Res. 102 (B3), 5005-5017, doi:10.1029/96JB03860.
 
 [2] Kouba J, and Héroux P (2001) Precise point positioning using IGS orbit and clock products. GPS Solutions 5 (2), 12-28, doi:10.1007/PL00012883.
 
## Capacités du GPSPACE 

Le logiciel GPSPACE a été développé en vue d'une précision géodésique la meilleure possible. La version publiée ici peut:
 - traiter les données GPS, Glonass, Galileo et/ou Beidou,
 - traiter en mode statique ou cinématique,
 - traiter les données double-fréquence,
 - traiter les données simple-fréquence (pseudodistances seules ou pseudistances et phases),
 - effectuer le lissage des paramètres variant dans le temps (horloges, délai troposphérique, positions cinématiques),
 - effectuer la résolution sub-optimale des ambiguïtés de phase (GPS seulement) avec les informations satellites appropriées.
 
Le logiciel GPSPACE génère des estimations de:
 - la position de l'antenne/repère en mode statique ou cinématique,
 - les états d'horloge récepteur spécifiques aux constellations observées,
 - le délai troposphérique et ses gradients EO et NS comme paramètres random-walk,
 - les ambiguïtés de phase.
 
Le logiciel GPSPACE accepte les données sous les formats suivants:
 - observations GNSS (RINEX 2.11),
 - message de navigation GPS (RINEX 2.11, MRTCA, RTCM),
 - orbites et horloges GNSS (SP3d, RINEX-CLOCK),
 - corrections aux orbites et horloges de navigation GPS (MRTCA, RTCM-SSR),
 - cartes de TEC ionosphériques (IONEX, harmoniques sphériques, MRTCA, RTCM-SSR),
 - calibrations absolues des antennes (ATX),
 - paramètres de surcharge des océans (HARPOS, BLQ),
 - modèles de mappage troposphériques (VMF1, grille GPT2 5x5),
 - coordonées du pôle (IGS erp).
 
## Style de programmation et documentation

Certaines parties du code source du logiciel GPSPACE remonte aux années 70. Sur les quelques 20 années depuis sa création et au fil des améliorations, le maintien de quelque standard de codage que ce soit n'a reçu que très peu d'attention. De plus aucune documentation n'est fournie, autres que les exemple d'utilisations que constituent les cas types. Par ailleurs, le logiciel a subi des tests intensifs durant ses années actives en soutien aux opérations du service CSRS-PPP en-ligne.

Droit d'auteur (c) Gouvernement du Canada, 2018. Sous termes de Licence MIT
