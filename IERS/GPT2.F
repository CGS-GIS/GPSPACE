      SUBROUTINE GPT2(DMJD,DLAT,DLON,HELL,NSTAT,IT,P,T,DT,E,AH,AW,UNDU)
*+
*  - - - - - - - - -
*   G P T 2 
*  - - - - - - - - -
*
*  This routine is part of the International Earth Rotation and
*  Reference Systems Service (IERS) Conventions software collection.
*
*
*  This subroutine determines pressure, temperature, temperature lapse rate, 
*  water vapour pressure, hydrostatic and wet mapping function coefficients 
*  ah and aw, and geoid undulation for specific sites near the Earth 
*  surface. It is based on a 5 x 5 degree external grid file ('gpt2_5.grd') 
*  with mean values as well as sine and cosine amplitudes for the annual and 
*  semiannual variation of the coefficients.
*
*  In general, Class 1, 2, and 3 models represent physical effects that
*  act on geodetic parameters while canonical models provide lower-level
*  representations or basic computations that are used by Class 1, 2, or
*  3 models.
* 
*  Status: Class 1 model	
* 
*     Class 1 models are those recommended to be used a priori in the
*     reduction of raw space geodetic data in order to determine
*     geodetic parameter estimates.
*     Class 2 models are those that eliminate an observational
*     singularity and are purely conventional in nature.
*     Class 3 models are those that are not required as either Class
*     1 or 2.
*     Canonical models are accepted as is and cannot be classified as a
*     Class 1, 2, or 3 model.
*
*  Given:
*     DMJD           d      Modified Julian Date (scalar, only one epoch
*                           per call is possible)
*     DLAT           d      Ellipsoidal latitude given in radians 
*                           [-pi/2:+pi/2] (vector)
*     DLON           d      Longitude given in radians
*                           [-pi:pi] or [0:2pi] (vector)
*     HELL           d      Ellipsoidal height in meters (vector)
*     NSTAT          d      Number of stations in DLAT, DLON, and HELL
*                           maximum possible: not relevant for Matlab version
*     IT             i      case 1: no time variation but static
*                           quantities
*                           case 0: with time variation (annual and 
*                           semiannual terms)
*  Returned:
*     P              d      Pressure given in hPa (vector of length
*                           NSTAT)
*     T              d      Temperature in degrees Celsius (vector of length
*                           NSTAT)
*     DT             d      Temperature lapse rate in degrees per km 
*                           (vector of length NSTAT)
*     E              d      Water vapour pressure in hPa
*                           (vector of length NSTAT)
*     AH             d      hydrostatic mapping function coefficient at 
*                           zero height (VMF1) 
*                           (vector of length NSTAT)
*     AW             d      wet mapping function coefficient
*                    d      (VMF1) (vector of length NSTAT)
*     UNDU           d      Geoid undulation in meters 
*                           (vector of length NSTAT)
*
*  Notes:
*
*  1) The hydrostatic mapping function coefficients have to be used with the
*  height dependent Vienna Mapping Function 1 (vmf_ht.f) because the
*  coefficients refer to zero height.
*
*  Test cases:
*  Example 1 (Vienna, 2 August 2012, with time variation):
*
* dmjd = 56141.d0
* dlat(1) = 48.20d0*pi/180.d0
* dlon(1) = 16.37d0*pi/180.d0
* hell(1) = 156.d0
* nstat = 1
* it = 0
*
* output:
* p = 1002.56 hPa
* T = 22.12 deg Celsius
* dT = -6.53 deg / km
* e = 15.63 hPa
* ah = 0.0012647
* aw = 0.0005726
* undu = 44.06 m
*
* Example 2 (Vienna, 2 August 2012, without time variation, 
* i.e. constant values):
*
* dmjd = 56141.d0
* dlat(1) = 48.20d0*pi/180.d0
* dlon(1) = 16.37d0*pi/180.d0
* hell(1) = 156.d0
* nstat = 1
* it = 1
*
* output:
* p = 1003.49 hPa
* T = 11.95 deg Celsius
* dT = -5.47 deg / km
* e = 9.58 hPa
* ah = 0.0012395
* aw = 0.0005560
* undu = 44.06 m
*
*  References:
*
*     Lagler, K., Schindelegger, M., Boehm, J., Krasna, H., and Nilsson, T.,
*     (2013), "GPT2: Empirical slant delay model for radio space geodetic
*     techniques," Geophys. Res. Lett., Vol. 40, pp. 1069-1073, DOI:
*     10.1002/grl.50288.    
*
*     Petit, G. and Luzum, B. (eds.), IERS Conventions (2010),
*     IERS Technical Note No. 36, BKG (2010)
*
*  Revisions:
* Klemens Lagler, 2 August 2012
* Johannes Boehm, 6 August 2012, revision
* Klemens Lagler, 21 August 2012, epoch change to January 1 2000
* Johannes Boehm, 23 August 2012, adding possibility to determine
*                                 constant field
* Beth Stetzler, 21 November 2012, Capitalized all variables for
*                                  FORTRAN 77 compatibility
* Johannes Boehm, 10 January 2013, correction for DLAT = -90 degrees
*                                  (problem found by Changyong He)
* Johannes Boehm, 21 May 2013,   bug with dmjd removed (input parameter
*                                was replaced unintentionally; problem
*                                found by Dennis Ferguson)
* Beth Stetzler, 31 May 2013, Updated reference and added 10 January
*                             2013 correction for DLAT = -90 degrees
*-----------------------------------------------------------------------

      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

      DIMENSION VEC(34)

      DIMENSION DLAT(64800),DLON(64800),HELL(64800)
      DIMENSION DT(64800),T(64800),P(64800),E(64800),
     .          AH(64800),AW(64800),UNDU(64800)

      DIMENSION PGRID(2592,5),TGRID(2592,5),QGRID(2592,5),DTGRID(2592,5)
     .         ,U(2592),HS(2592),AHGRID(2592,5),AWGRID(2592,5)

      DIMENSION UNDUL(4),QL(4),DTL(4),TL(4),PL(4),AHL(4),AWL(4)

      DIMENSION INDX(4) 

      CHARACTER LINE*80

!  Define the mean gravity in m/s**2
      GM = 9.80665D0
!  Define the molar mass of dry air in kg/mol
      DMTR = 28.965D-3;
!  Universal gas constant in J/K/mol
      RG = 8.3143D0
!  Pi
      PI = 3.1415926535D0

!  Change the reference epoch to January 1 2000
      DMJD1 = DMJD-51544.5;

!  Define factors for amplitudes
      IF (IT.EQ.1) THEN  ! constant parameters
        COSFY = 0.D0
        COSHY = 0.D0
        SINFY = 0.D0
        SINHY = 0.D0
      ELSE 
        COSFY = DCOS(DMJD1/365.25*2*PI)
        COSHY = DCOS(DMJD1/365.25*4*PI)
        SINFY = DSIN(DMJD1/365.25*2*PI)
        SINHY = DSIN(DMJD1/365.25*4*PI)
      END IF

!  Read the external gridfile
!  The grid file was obtained from the website
!  http://acc.igs.org/tropo/gpt2_5.grd on 11/6/2012
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C Modification : GPSPPP : beg
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
c     OPEN(11,FILE='gpt2_5.grd')
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C Modification : GPSPPP : end
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

!  Read first comment line
      READ (11,'(A80)') LINE

!  Loop over grid points
      DO N = 1,2592
        
        ! read data line
        READ (11,*) VEC
        PGRID(N,1:5)  = VEC(3:7)           ! pressure in Pascal
        TGRID(N,1:5)  = VEC (8:12)         ! temperature in Kelvin
        QGRID(N,1:5)  = VEC(13:17)/1000.D0 ! specific humidity in kg/kg
        DTGRID(N,1:5) = VEC(18:22)/1000.D0 ! temperature lapse rate in Kelvin/m
        U(N)          = VEC(23)            ! geoid undulation in m
        HS(N)         = VEC(24)            ! orthometric grid height in m
        AHGRID(N,1:5) = VEC(25:29)/1000.D0 ! hydrostatic mapping function coefficient, dimensionless
        AWGRID(N,1:5) = VEC(30:34)/1000.D0 ! wet mapping function coefficient, dimensionless

      END DO
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C Modification : GPSPPP : beg
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
c     CLOSE (11)
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C Modification : GPSPPP : end
c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

!  Loop over stations
      DO K = 1,NSTAT
    
        ! only positive longitude in degrees
        IF (DLON(K).LT.0.D0) THEN
          PLON = (DLON(K) + 2.D0*PI)*180.D0/PI
        ELSE
          PLON = DLON(K)*180.D0/PI
        END IF
        ! transform to polar distance in degrees
        PPOD = (-DLAT(K) + PI/2.D0)*180.D0/PI 

        ! find the index (line in the grid file) of the nearest point
        IPOD = FLOOR((PPOD+5.D0)/5.D0) 
        ILON = FLOOR((PLON+5.D0)/5.D0)
    
        ! normalized (to one) differences, can be positive or negative
        DIFFPOD = (PPOD - (IPOD*5.D0 - 2.5D0))/5.D0
        DIFFLON = (PLON - (ILON*5.D0 - 2.5D0))/5.D0

        ! added by HCY
        IF (IPOD.EQ.37) THEN
          IPOD = 36
        END IF 

        ! get the number of the corresponding line
        INDX(1) = (IPOD - 1)*72 + ILON 

        ! near the poles: nearest neighbour interpolation, otherwise: bilinear
        IBILINEAR = 0
        IF ((PPOD.GT.2.5D0).AND.(PPOD.LT.177.5D0)) THEN 
          IBILINEAR = 1          
        END IF         
    
        ! case of nearest neighbourhood
        IF (IBILINEAR.EQ.0) THEN

          IX = INDX(1)
        
          ! transforming ellipsoidial height to orthometric height
          UNDU(K) = U(IX)
          HGT = HELL(K)-UNDU(K)
            
          ! pressure, temperature at the height of the grid
          T0 = TGRID(IX,1) + 
     .         TGRID(IX,2)*COSFY + TGRID(IX,3)*SINFY + 
     .         TGRID(IX,4)*COSHY + TGRID(IX,5)*SINHY
          P0 = PGRID(IX,1) + 
     .         PGRID(IX,2)*COSFY + PGRID(IX,3)*SINFY + 
     .         PGRID(IX,4)*COSHY + PGRID(IX,5)*SINHY
         
          ! specific humidity
          Q = QGRID(IX,1) + 
     .        QGRID(IX,2)*COSFY + QGRID(IX,3)*SINFY + 
     .        QGRID(IX,4)*COSHY + QGRID(IX,5)*SINHY
            
          ! lapse rate of the temperature
          DT(K) = DTGRID(IX,1) + 
     .            DTGRID(IX,2)*COSFY + DTGRID(IX,3)*SINFY + 
     .            DTGRID(IX,4)*COSHY + DTGRID(IX,5)*SINHY 

          ! station height - grid height
          REDH = HGT - HS(IX)

          ! temperature at station height in Celsius
          T(K) = T0 + DT(K)*REDH - 273.15D0
        
          ! temperature lapse rate in degrees / km
          DT(K) = DT(K)*1000.D0

          ! virtual temperature in Kelvin
          TV = T0*(1.D0 + 0.6077D0*Q)
        
          C = GM*DMTR/(RG*TV)
        
          ! pressure in hPa
          P(K) = (P0*EXP(-C*REDH))/100.D0
        
          ! water vapour pressure in hPa
          E(K) = (Q*P(K))/(0.622D0 + 0.378D0*Q);
            
          ! hydrostatic coefficient ah 
          AH(K) = AHGRID(IX,1) + 
     .            AHGRID(IX,2)*COSFY + AHGRID(IX,3)*SINFY + 
     .            AHGRID(IX,4)*COSHY + AHGRID(IX,5)*SINHY
            
          ! wet coefficient aw
          AW(K) = AWGRID(IX,1) + 
     .            AWGRID(IX,2)*COSFY + AWGRID(IX,3)*SINFY + 
     .            AWGRID(IX,4)*COSHY + AWGRID(IX,5)*SINHY           
                    
        ELSE ! bilinear interpolation
        
          IPOD1 = IPOD + INT(SIGN(1.D0,DIFFPOD))
          ILON1 = ILON + INT(SIGN(1.D0,DIFFLON))
          IF (ILON1.EQ.73) THEN
            ILON1 = 1
          END IF
          IF (ILON1.EQ.0) THEN
            ILON1 = 72
          END IF
        
          ! get the number of the line
          INDX(2) = (IPOD1 - 1)*72 + ILON   !% along same longitude
          INDX(3) = (IPOD  - 1)*72 + ILON1  !% along same polar distance
          INDX(4) = (IPOD1 - 1)*72 + ILON1  !% diagonal
        
          DO L = 1,4
                
            ! transforming ellipsoidial height to orthometric height:
            ! Hortho = -N + Hell
            UNDUL(L) = U(INDX(L));
            HGT = HELL(K)-UNDUL(L);
        
            ! pressure, temperature at the heigtht of the grid
            T0 = TGRID(INDX(L),1) + 
     .           TGRID(INDX(L),2)*COSFY + TGRID(INDX(L),3)*SINFY + 
     .           TGRID(INDX(L),4)*COSHY + TGRID(INDX(L),5)*SINHY;
            P0 = PGRID(INDX(L),1) + 
     .           PGRID(INDX(L),2)*COSFY + PGRID(INDX(L),3)*SINFY + 
     .           PGRID(INDX(L),4)*COSHY + PGRID(INDX(L),5)*SINHY

            ! humidity 
            QL(L) = QGRID(INDX(L),1) + 
     .              QGRID(INDX(L),2)*COSFY + QGRID(INDX(L),3)*SINFY + 
     .              QGRID(INDX(L),4)*COSHY + QGRID(INDX(L),5)*SINHY
 
            ! reduction = stationheight - gridheight
            HS1 = HS(INDX(L))
            REDH = HGT - HS1

            ! lapse rate of the temperature in degree / m
            DTL(L) = DTGRID(INDX(L),1) + 
     .               DTGRID(INDX(L),2)*COSFY + DTGRID(INDX(L),3)*SINFY +
     .               DTGRID(INDX(L),4)*COSHY + DTGRID(INDX(L),5)*SINHY 

            ! temperature reduction to station height
            TL(L) = T0 + DTL(L)*REDH - 273.15D0

            ! virtual temperature
            TV = T0*(1.D0+0.6077D0*QL(L))  
            C = GM*DMTR/(RG*TV)
            
            ! pressure in hPa
            PL(L) = (P0*EXP(-C*REDH))/100.D0
            
            ! hydrostatic coefficient ah
            AHL(L) = AHGRID(INDX(L),1) + 
     .               AHGRID(INDX(L),2)*COSFY + AHGRID(INDX(L),3)*SINFY +
     .               AHGRID(INDX(L),4)*COSHY + AHGRID(INDX(L),5)*SINHY
            
            ! wet coefficient aw
            AWL(L) = AWGRID(INDX(L),1) + 
     .               AWGRID(INDX(L),2)*COSFY + AWGRID(INDX(L),3)*SINFY +
     .               AWGRID(INDX(L),4)*COSHY + AWGRID(INDX(L),5)*SINHY
            
          END DO
            
          DNPOD1 = ABS(DIFFPOD)  !% distance nearer point
          DNPOD2 = 1.D0 - DNPOD1 !% distance to distant point
          DNLON1 = ABS(DIFFLON) 
          DNLON2 = 1.D0 - DNLON1
        
          ! pressure
          R1 = DNPOD2*PL(1)+DNPOD1*PL(2)
          R2 = DNPOD2*PL(3)+DNPOD1*PL(4)
          P(K) = DNLON2*R1+DNLON1*R2
            
          ! temperature
          R1 = DNPOD2*TL(1)+DNPOD1*TL(2)
          R2 = DNPOD2*TL(3)+DNPOD1*TL(4)
          T(K) = DNLON2*R1+DNLON1*R2
        
          ! temperature in degree per km
          R1 = DNPOD2*DTL(1)+DNPOD1*DTL(2)
          R2 = DNPOD2*DTL(3)+DNPOD1*DTL(4)
          DT(K) = (DNLON2*R1+DNLON1*R2)*1000.D0
            
          ! humidity
          R1 = DNPOD2*QL(1)+DNPOD1*QL(2)
          R2 = DNPOD2*QL(3)+DNPOD1*QL(4)
          Q = DNLON2*R1+DNLON1*R2
          E(K) = (Q*P(K))/(0.622D0+0.378D0*Q)
            
          ! hydrostatic
          R1 = DNPOD2*AHL(1)+DNPOD1*AHL(2)
          R2 = DNPOD2*AHL(3)+DNPOD1*AHL(4)
          AH(K) = DNLON2*R1+DNLON1*R2
           
          ! wet
          R1 = DNPOD2*AWL(1)+DNPOD1*AWL(2)
          R2 = DNPOD2*AWL(3)+DNPOD1*AWL(4)
          AW(K) = DNLON2*R1+DNLON1*R2
        
          ! undulation
          R1 = DNPOD2*UNDUL(1)+DNPOD1*UNDUL(2)
          R2 = DNPOD2*UNDUL(3)+DNPOD1*UNDUL(4)
          UNDU(K) = DNLON2*R1+DNLON1*R2
                    
        END IF
      END DO

* Finished.

*+----------------------------------------------------------------------
*
*  Copyright (C) 2008
*  IERS Conventions Center
*
*  ==================================
*  IERS Conventions Software License
*  ==================================
*
*  NOTICE TO USER:
*
*  BY USING THIS SOFTWARE YOU ACCEPT THE FOLLOWING TERMS AND CONDITIONS
*  WHICH APPLY TO ITS USE.
*
*  1. The Software is provided by the IERS Conventions Center ("the
*     Center").
*
*  2. Permission is granted to anyone to use the Software for any
*     purpose, including commercial applications, free of charge,
*     subject to the conditions and restrictions listed below.
*
*  3. You (the user) may adapt the Software and its algorithms for your
*     own purposes and you may distribute the resulting "derived work"
*     to others, provided that the derived work complies with the
*     following requirements:
*
*     a) Your work shall be clearly identified so that it cannot be
*        mistaken for IERS Conventions software and that it has been
*        neither distributed by nor endorsed by the Center.
*
*     b) Your work (including source code) must contain descriptions of
*        how the derived work is based upon and/or differs from the
*        original Software.
*
*     c) The name(s) of all modified routine(s) that you distribute
*        shall be changed.
* 
*     d) The origin of the IERS Conventions components of your derived
*        work must not be misrepresented; you must not claim that you
*        wrote the original Software.
*
*     e) The source code must be included for all routine(s) that you
*        distribute.  This notice must be reproduced intact in any
*        source distribution. 
*
*  4. In any published work produced by the user and which includes
*     results achieved by using the Software, you shall acknowledge
*     that the Software was used in obtaining those results.
*
*  5. The Software is provided to the user "as is" and the Center makes
*     no warranty as to its use or performance.   The Center does not
*     and cannot warrant the performance or results which the user may
*     obtain by using the Software.  The Center makes no warranties,
*     express or implied, as to non-infringement of third party rights,
*     merchantability, or fitness for any particular purpose.  In no
*     event will the Center be liable to the user for any consequential,
*     incidental, or special damages, including any lost profits or lost
*     savings, even if a Center representative has been advised of such
*     damages, or for any claim by any third party.
*
*  Correspondence concerning IERS Conventions software should be
*  addressed as follows:
*
*                     Gerard Petit
*     Internet email: gpetit[at]bipm.org
*     Postal address: IERS Conventions Center
*                     Time, frequency and gravimetry section, BIPM
*                     Pavillon de Breteuil
*                     92312 Sevres  FRANCE
*
*     or
*
*                     Brian Luzum
*     Internet email: brian.luzum[at]usno.navy.mil
*     Postal address: IERS Conventions Center
*                     Earth Orientation Department
*                     3450 Massachusetts Ave, NW
*                     Washington, DC 20392
*
*
*-----------------------------------------------------------------------
      END      
