c     Matrix elements here are non-reduced (<|V|>) The difference is: <|V|> = sqrt(2J+1) <||V||>
c$$$      subroutine vdme(nchmi,Nmaxi,Ni,Li,lai,si,lpari,nspmi,loi,
c$$$     >   Ci,fli,maxfi,minfi,npki,chili,minci,
c$$$     >   ortint,KJ,dwpot,
c$$$     >   vdon,VVD,nchf,nchi,na,nam,namax)
      subroutine vdme(nze,nchmi,Nmaxi,Ni,Li,lai,si,lpari,nspmi,loi,
     >   Ci,fli,maxfi,minfi,npki,chili,minci,
     >   nchmf,Nmaxf,Nf,Lf,laf,sf,lparf,nspmf,lof,
     >   Cf,flf,maxff,minff,npkf,chilf,mincf,ortint,KJ,dwpot,
     >   vdon,VVD,nchf,nchi,na,nam,namax)
      include 'par.f'
      double precision Z
      common /Zatom/ Z
      integer lai(Nmaxi), si(Nmaxi), lpari(Nmaxi)
      integer laf(Nmaxf), sf(Nmaxf), lparf(Nmaxf)
      double precision Ci(Nmaxi,namax,namax),Cf(Nmaxf,namax,namax),
     >   ortint(nspmax,nspmax)
      dimension loi(nspmi), lof(nspmf),npki(nchmi+1),npkf(nchmf+1)
      dimension fli(maxr,nspmax),maxfi(nspmi),minfi(nspmi)
      dimension flf(maxr,nspmax),maxff(nspmf),minff(nspmf)
      dimension chili(nr,npki(nchmi+1)-1), minci(npki(nchmi+1)-1)
      dimension chilf(nr,npkf(nchmf+1)-1), mincf(npkf(nchmf+1)-1)
      dimension formout(maxr),chiform(maxr,kmax),dwpot(maxr,nchan)
      dimension VVD(npkf(nchmf+1)-1,npki(nchmi+1))
      dimension  Vang(0:ltmax), upot(maxr), vdon(nchan,nchan,0:1)
      common /meshrr/ nr, gridr(nmaxr,3)
      dimension temp(maxr)
c      logical zeroc
      logical diag_ME
      real tmp_const(0:ltmax)
      dimension na(nspmCI,KNM), nam(KNM)
      common /atompol/ atompol(maxr), ipolmin, ipolmax, ipol
      
c     Note : antisymmetrization is included through CI coefficients.
c     
      hat(l)=sqrt(2.0 * l + 1.0)

c$$$     >   nchmf,Nmaxf,Nf,Lf,laf,sf,lparf,nspmf,lof,
c$$$     >   Cf,flf,maxff,minff,npkf,chilf,mincf,
c$$$      nchmf = nchmi
c$$$      Nmaxf = Nmaxi
c$$$      Nf = Ni
c$$$      Lf = Li
c$$$      laf = lai
c$$$      sf = si
c$$$      lparf = lpari
c$$$      nspmf = nspmi
c$$$      lof = loi
c$$$      Cf = Ci
c$$$      flf = fli
c$$$      maxff = maxfi
c$$$      minff = minfi
c$$$      npkf = npki
c$$$      chilf = chili
c$$$      mincf = minci
      ze = 2.0

      pnorm = 2.0/acos(-1.0)
      do i = 1, maxr
         temp(i) = 0.0
      enddo

      diag_ME = Ni.eq.Nf   ! set true if this is diagonal ME, to be used for subtraction of the nuclear term
      
c     
c     These are 2 channels loops (nch = (L,la(N),s(N))
c     where L is projectile ang.mom., N is number of physical channel,
c     la(N),s(N)  are  target ang. and spin mom..
c$$$      do 40  nchi=1,nchmi
c$$$         call   getchinfo2 (Nmaxi,lai,nchi, KJ, Ni, Li)
         nqmi = npki(nchi+1) - npki(nchi)
         do i = 1, nr
            upot(i) = dwpot(i,nchi) / ze 
         enddo 
c$$$         do 30  nchf=nchi,nchmf
c$$$            call   getchinfo2 (Nmaxf,laf,nchf, KJ, Nf, Lf)  
            nqmf = npkf(nchf+1) - npkf(nchf)
c         call   getchinfo2 (nchf,Nf,KJ,temp,ener,laf,naf,Lf) 
            do i = 1, nr
               formout(i) = 0.0
            enddo
            minform = nr
            maxform = 0

            if(si(Ni).ne.sf(Nf)) goto 30
            rK=KJ
            lli=lai(Ni)
            rLi=Li
            rlli=lli
            llf=laf(Nf)
            rLf=Lf
            rllf=llf
c     Ni,Nf  -   numbers of physical channels
c     s(Ni)=s(Nf) for direct VME

c     lambda loop: to avoid recalculations of 6J and CGC that do not depend
c     on ang. momenta of s.p.functions
      tmp_hat =  hat(lli)*hat(llf)*hat(Li)
      lamtop1=min(Li+Lf,lli+llf)
      lambot1=max(iabs(Li-Lf),iabs(lli-llf))
      do lam=lambot1,lamtop1
         rlam=lam
         tmp_const(lam) =  tmp_hat *
     >        CGC(rLi,0.,rlam,0.,rLf,0.)*
     >        COF6J(rLf,rllf,rK,rlli,rLi,rlam)*
     >        (-1)**(llf+Li+KJ+lli+lam)
      end do

c     these are 2 s.p. loops on s.p. functions of the coordinate r1
            do 68 jnf1=1,nam(Nf)
               nf1 = na(jnf1,Nf)
               lf1=lof(nf1)
               rlf1=lf1
               tmp2 = (-1)**(lf1)
               do 67 jni1=1,nam(Ni)
                  ni1 = na(jni1,Ni)
                  li1=loi(ni1)
                  rli1=li1
                  tmp1 = tmp2 * hat(li1) 
c     lambda loop:
                  lamtop=min(li1+lf1,lamtop1)
                  lambot=max(iabs(li1-lf1),lambot1)
                        
c     lambda loop for calculation of the angular coefficent:
                  do 5 lam=lambot,lamtop
                     rlam=lam
                     Vang(lam)=0.0
                     const = tmp_const(lam) * tmp1 *
     >                  CGC(rli1,0.,rlam,0.,rlf1,0.)
                     if (const.eq.0.0) go to 5

c     These are loops on s.p. functions of the coordinate r2,
c     coordinate r2 is not affected by V(r0,r1), but  nf2 is not necessary 
c     equal to ni2 because nonorthogonal s.p. basis is used, but li2=lf2.

                     lf2_old = -1
                     do 10 jnf2=1,nam(Nf)
                        nf2 = na(jnf2,Nf)
                        lf2=lof(nf2)
                        rlf2=lf2
                        tmp_Cf = Cf(Nf,jnf1,jnf2)
                        do 20 jni2=1,nam(Ni)
                           ni2 = na(jni2,Ni)
                           if(Ci(Ni,jni1,jni2).eq.0.0d0) goto 20
                           rli2 = loi(ni2)
                           const2 = ortint(ni2,nf2) * tmp_Cf * 
     >                          Ci(Ni,jni1,jni2)
                           if (const2.eq.0.0) goto 20
                           if(lf2.ne.lf2_old) then
                              tmp_6J = (-1)**lf2 *
     >                             COF6J(rlf2,rlf1,rllf,rlam,rlli,rli1) 
                              lf2_old = lf2
                           end if
                           Vang(lam) = Vang(lam) + const2 * tmp_6J
                           
c     end ni2,nf2 loops
 20                     continue
 10                  continue
                     
                     Vang(lam) = Vang(lam) * const
c     end lambda loop                    
 5                continue 
                  do lam=lambot,lamtop
                     if (Vang(lam).ne.0.0) then
                        call getformout(lam,Vang(lam),upot,
     >                     fli(1,ni1),flf(1,nf1),
     >                     minfi(ni1),minff(nf1),
     >                     maxfi(ni1),maxff(nf1),nr,diag_ME,
     >                     formout,minform,maxform)
                     end if
                  end do
c     end ni1,nf1 loops
 67            continue
 68         continue 
C  The following print out should be zero if the distorting potential is
C  appropriately chosen
c$$$  if (upot(1).ne.0.0) then
c$$$               do i = minform, maxform
c$$$                  write(98,*) gridr(i,1), formout(i)
c$$$               enddo
c$$$            endif 

c     For Hg, modify diag. matrix elelments by additional atom-projectile
c     polarization potential. Add atompol(i) to formout(i):
            if(diag_ME .and. ipol .eq. 1) then
               minform = min(minform,ipolmin)
               maxform = max(maxform,ipolmax)
               formout(1:minform) = 0.0
               formout(maxform:maxr) = 0.0
               formout(minform:maxform) =  formout(minform:maxform) +
     >            atompol(minform:maxform)
            end if
            
            if (nchi.eq.nchf.and.nqmi.eq.1.and.dwpot(1,nchi).eq.0.0)
     >         then
C  Define the channel dependent distorting potential when running the
C  Born case. The units are Rydbergs.
               do i = minform, maxform
                  dwpot(i,nchi) = ze * formout(i) * 2.0
               enddo
            endif

c     momentum loops
            kistep = npki(nchi) - 1
            const = - nze * pnorm * ze
            do i = minform, maxform
               temp(i) = formout(i) / gridr(i,3)
            enddo
               
            do ki=npki(nchi), npki(nchi+1) - 1
               minki = max(minform, minci(ki))
               do i = minki, maxform
                  chiform(i,ki-kistep) = temp(i) * chili(i,ki)
               enddo
            enddo
            kistart = npki(nchi)
            kistop = npki(nchi+1) - 1
            quart = 0.0
            if (si(Ni).eq.1.0) quart = 1.0
C Note si(Ni) = sf(Nf) here
c$$$c$par doall
            tmp = 0.0
            do ki=kistart, kistop
               minki = max(minform, minci(ki))
               kii = ki - kistep
               do 90 kf = npkf(nchf), npkf(nchf+1) - 1
                  mini = max(minki, mincf(kf))
                  n = maxform - mini + 1
                  if (kf.lt.ki.or.n.le.0) go to 90
                  tmp = dot_product(chilf(mini:maxform,kf),
     >               chiform(mini:maxform,kii))
c$$$                  tmp = sdot(n,chilf(mini,kf),1,chiform(mini,kii),1)
                  VVD(kf,ki) = VVD(kf,ki) + tmp * const
C  QUART is used to make sure that the quartet V matrix elements are
C  nonzero for triplet-triplet transitions only. The multiplication
C  by QUART zeros the contribution from the core.
                  VVD(ki,kf+1) = (VVD(ki,kf+1) + tmp * const) * quart
c     end ki,kf loops
 90            continue 
            end do
            vdon(nchf,nchi,0) = vdon(nchf,nchi,0) + tmp * const
            vdon(nchi,nchf,0) = vdon(nchf,nchi,0)
            vdon(nchf,nchi,1) = (vdon(nchf,nchi,1)+tmp*const) * quart
            vdon(nchi,nchf,1) = vdon(nchf,nchi,1)
c     end nchi,nchf loops
 30      continue       
 40   continue       
      return
      end
c*********************************************************************
      subroutine ve1me(nchmi,Nmaxi,Ni,Li,lai,si,lpari,nspmi,loi,
     >   Ci,fli,maxfi,minfi,npki,chili,minci,
     >   nchmf,Nmaxf,Nf,Lf,laf,sf,lparf,nspmf,lof,
     >   Cf,flf,maxff,minff,npkf,chilf,mincf,
     >   ortint,KJ,VE1,nchf,nchi,
     >   chiform,minchiform,maxchiform,na,nam,namax)
      include 'par.f'
      double precision Z
      common /Zatom/ Z
      integer lai(Nmaxi), si(Nmaxi), lpari(Nmaxi)
      integer laf(Nmaxf), sf(Nmaxf), lparf(Nmaxf)
      double precision Ci(Nmaxi,namax,namax),Cf(Nmaxf,namax,namax),
     >   ortint(nspmax,nspmax)
      dimension loi(nspmi), lof(nspmf),
     >   npki(nchmi+1),npkf(nchmf+1)
      dimension  fli(maxr,nspmax),maxfi(nspmi),minfi(nspmi)
      dimension  flf(maxr,nspmax),maxff(nspmf),minff(nspmf)
      dimension chili(nr,npki(nchmi+1)-1), minci(npki(nchmi+1)-1)
      dimension chilf(nr,npkf(nchmf+1)-1), mincf(npkf(nchmf+1)-1)
      dimension VE1(npkf(nchmf+1)-1,npki(nchmi+1))
      dimension formout(maxr), chiform(maxr,kmax),
     >   minchiform(kmax),maxchiform(kmax)
      double precision VA, tmp_Vang, tmp_Ci, hat, pnorm
      dimension Vang(0:ltmax,nspmCI) 
      common /meshrr/ nr, gridr(nmaxr,3)
      dimension na(nspmCI,KNM), nam(KNM)


c     Note : antisymmetrization is included through CI coefficients.
c     
      hat(l)=dsqrt(2.0*l+1.0D0)
      ze = 2.0
      pnorm = 2.0d0/dacos(-1.0d0)
      
C     For large J we will have lambda that is too big.
      if (KJ .gt. ltmax + 3) return
c     
c     These are 2 channels loops (nch = (L,ll(N),ls(N))
c     where L is projectile ang.mom., N is number of physical channel,
c     la(N),sa(N)  are  target ang. and spin mom..
c$$$  do  40  nchi=1,nchmi
      nqmi = npki(nchi+1) - npki(nchi)
c$$$  call   getchinfo2 (Nmaxi,lai,nchi, KJ, Ni, Li) 
c     call   getchinfo2 (nchi,Ni,KJ,temp,ener,lai,nai,Li) 
c$$$  do  30  nchf=nchi,nchmf
      nqmf = npkf(nchf+1) - npkf(nchf)
c$$$  call   getchinfo2 (Nmaxf,laf,nchf, KJ, Nf, Lf)  
c     call   getchinfo2 (nchf,Nf,KJ,temp,ener,laf,naf,Lf) 
      rK=KJ
      lli=lai(Ni)
      llf=laf(Nf)
      lsi=si(Ni)
      lsf=sf(Nf)
      rLi=Li
      rlli=lli
      rLf=Lf
      rllf=llf
      rsi=lsi
      rsf=lsf
c     Ni,Nf  -   numbers of physical chanels
c     
c     find maxumum value for maxfi(ni1) to be used in getformout2() routine.
      m_maxfi = 0
      do jni1=1,nam(Ni)   
         ni1= na(jni1,Ni)
         m_maxfi = max(m_maxfi,maxfi(ni1))
      end do

      tmp1_hat = hat(lli)*hat(llf)*hat(Li)*hat(lsi)*hat(lsf)
c     these are 2 s.p. loops on s.p. functions of the coordinate r1 and r0
      do 68 jnf1=1,nam(Nf)
         nf1 = na(jnf1,Nf)
         lf1=lof(nf1)
         rlf1=lf1

         do jni1=1,nam(Ni)
            do lam=0,ltmax
               Vang(lam,jni1)=0.0
            end do
         end do
         m_lamtop = -1
         m_lambot = ltmax

         do 67 jni1=1,nam(Ni)
            ni1= na(jni1,Ni)
            li1=loi(ni1)
            rli1=li1
            tmp_hat = tmp1_hat * hat(li1)

c     lambda loop for calculation of the angular coefficent:
            lamtop=min(li1+Lf,lf1+Li,ltmax)
            lambot=max(iabs(li1-Lf),iabs(lf1-Li))
            m_lamtop = max(m_lamtop, lamtop)
            m_lambot = min(m_lambot, lambot)
            do 140 lam=lambot,lamtop
               rlam=lam
               tmp_Vang=0.0
               const = tmp_hat *
     >              CGC(rLi,0.,rlam,0.,rlf1,0.)*
     >              CGC(rli1,0.,rlam,0.,rLf,0.)*
c$$$  >                     COF6J(0.5,0.5,rsf,0.5,S,rsi)*
     >              (-1)**(Li+lli+lf1+lam+llf+KJ+1+lsi+lsf)
               if (const.eq.0.0) go to 140
c     These are loops on s.p. functions of the coordinate r2,
c     coordinate r2 is not affected by V(r0,r1), but  nf2 is not necessary 
c     equal to ni2 because nonorthogonal s.p. basis is used, but li2=lf2.
               do 20 jni2=1,nam(Ni)
                  ni2 = na(jni2,Ni)
                  if(Ci(Ni,jni1,jni2).eq.0.0D0) go to 20
                  tmp_Ci = Ci(Ni,jni1,jni2)
                  li2=loi(ni2)
                  rli2=li2
                  do 10 jnf2=1,nam(Nf)
                     nf2 = na(jnf2,Nf)
                     if(Cf(Nf,jnf1,jnf2).eq.0.0D0) go to 10
                     if(ortint(nf2,ni2).eq.0.0D0)goto 10
                     lf2=lof(nf2)
                     rlf2=lf2
c     ni1,ni2,nf1,nf2 - number of the s.p. states,
c     li1,li2,lf1,lf2 - their angular momentum.
c     this is loop on j that arise after angular momentum recoupling
                     jtop=min(Li+li2,lam+llf)
                     jbot=max(iabs(Li-li2),iabs(lam-llf))
                     VA = 0.0D0
                     do j=jbot,jtop
                        rj=j
                        VA = VA + DBLE((2*j+1.)*
     >                       COF6J(rLi,rli2,rj,rli1,rK,rlli)*
     >                       COF6J(rlf2,rlf1,rllf,rlam,rj,rLi)*
     >                       COF6J(rLf,rllf,rK,rj,rli1,rlam))
                     end do
                     tmp_Vang = tmp_Vang + VA*
     >                    tmp_Ci*Cf(Nf,jnf1,jnf2)*
     >                    ortint(nf2,ni2)*(-1)**lf2
c     end ni2,nf2 loops
 10               continue
 20            continue
               Vang(lam,jni1) = tmp_Vang * const
c     end lambda loop:
 140        continue
            
c     end ni1 loop
 67      continue
         
         do 160 lam=m_lambot,m_lamtop
            do jni1=1,nam(Ni)
c     if at least one Vang() is nonzero for given  lam,jnf1 
c     then call getformout() for these lam,jnf1 and all ki
               if(Vang(lam,jni1).ne.0.0) go to 150
            end do
c     if programm get to this point then all Vang() are zero for 
c     given lam,jnf1  therefore no need to call getformout2()
            go to 160
 150        do ki = 1, nqmi
               kii = npki(nchi) + ki - 1
c     calculation of radial integrals
               call getformout2(lam,chili(1,kii),flf(1,nf1),
     >              minci(kii),minff(nf1),
     >              nr,maxff(nf1),m_maxfi,
     >              formout,minform,maxform)

               do jni1=1,nam(Ni)   
                  tmp = Vang(lam,jni1)
                  if(tmp.ne.0.0) then
                     ni1= na(jni1,Ni)
                     minki = max(minform, minfi(ni1))
                     maxki = min(maxform, maxfi(ni1))
                     do i = minki, maxki
                        chiform(i,ki) = chiform(i,ki) +
     >                       formout(i)*fli(i,ni1)*tmp
                     enddo
                     minchiform(ki) = min(minki,minchiform(ki))
                     maxchiform(ki) = max(maxki,maxchiform(ki))
                  end if
               enddo
            end do             
 160     continue 
c     end nf1 loop
 68   continue


      TSpin = 0.5
      c0p5 = pnorm * ze * COF6J(0.5,0.5,rsf,0.5,TSpin,rsi)
      if (lsi.eq.lsf.and.lsf.eq.1) then
         TSpin = 1.5
         c1p5  = pnorm * ze * COF6J(0.5,0.5,rsf,0.5,TSpin,rsi)
      else
         c1p5 = 0.0
      endif 
c$$$c$par doall
      do ki = 1, nqmi
         kii = npki(nchi) + ki - 1
         do 90 kf = 1, nqmf
            kff = npkf(nchf) + kf - 1
            mini = max(minchiform(ki), mincf(kff))
            n = maxchiform(ki) - mini + 1
            if (kff.lt.kii.or.n.le.0) go to 90
            tmp = dot_product(chilf(mini:maxchiform(ki),kff),
     >         chiform(mini:maxchiform(ki),ki))
c$$$            tmp = sdot(n,chilf(mini,kff),1,chiform(mini,ki),1)
            VE1(kff,kii) = VE1(kff,kii) - c0p5 * tmp
            VE1(kii,kff+1)=VE1(kii,kff+1) - c1p5 * tmp
c     end ki,kf loops
 90      continue 
      end do
c     end nchi,nchf loops
c$$$ 30   continue       
c$$$ 40   continue       
      return
      end
c***************************************************************************
c     this subroutine calculates matrix elements for V(r0,r2).
      subroutine ve2me(nchmi,Nmaxi,Ni,Li,lai,si,lpari,nspmi,loi,
     >   Ci,fli,maxfi,minfi,npki,chili,minci,
     >   nchmf,Nmaxf,Nf,Lf,laf,sf,lparf,nspmf,lof,
     >   Cf,flf,maxff,minff,npkf,chilf,mincf,
     >   ortint,ortchil,flchil,KJ,gridk,VE2,nchf,nchi,
     >   chiform,minchiform,maxchiform,na,nam,namax)
      include 'par.f'
      double precision Z, fangint
      common /Zatom/ Z
      integer lai(Nmaxi), si(Nmaxi), lpari(Nmaxi)
      integer laf(Nmaxf), sf(Nmaxf), lparf(Nmaxf)
      double precision Ci(Nmaxi,namax,namax),Cf(Nmaxf,namax,namax),
     >   ortint(nspmax,nspmax)
      dimension loi(nspmi), lof(nspmf), npki(nchmi+1), npkf(nchmf+1)
      dimension  fli(maxr,nspmax),maxfi(nspmi),minfi(nspmi)
      dimension  flf(maxr,nspmax),maxff(nspmf),minff(nspmf)
      dimension chili(nr,npki(nchmi+1)-1), minci(npki(nchmi+1)-1)
      dimension chilf(nr,npkf(nchmf+1)-1), mincf(npkf(nchmf+1)-1)
      dimension chiform(maxr,kmax),minchiform(kmax),maxchiform(kmax)
      dimension Ang(kmax), Ang2(kmax)
      double precision  hat,pnorm,e1r
      dimension ortchil(npki(nchmi+1)-1,nspmf),
     >   flchil(npki(nchmi+1)-1,nspmf)
      dimension VE2(npkf(nchmf+1)-1,npki(nchmi+1))
      common /meshrr/ nr, gridr(nmaxr,3)
      dimension gridk(kmax,nchan)
      common/hame1/ e1r(nspmax,nspmax)
      logical ange0
      dimension na(nspmCI,KNM), nam(KNM)
c      common /vrelcor/ vrel(2000), rrel(0:lomax), iCR
      
c     Note : antisymmetrization is included through CI coefficients.
c
      hat(l)=dsqrt(2.0*l+1.0D0)
      ze = 2.0
      pnorm = 2.0d0/dacos(-1.0d0)

c
c     Note: if calculate e-2e matrix elements make lomax (par.f) big enough.
c     Li=lf1, therefore  Li  could not be bigger then lomax. It makes
c     limitations on value of KJ: |KJ-lli|<=Li<=KJ+lli (0<=lli<=2*lomax),
c     hence maximum value of KJ is:
      Ke2 = 3*lomax
      if(KJ.gt.Ke2)  return
      lofmax = 0
      do nf1 = 1, nspmf
         lofmax = max(lofmax,lof(nf1))
      enddo

c     These are 2 channels loops (nch = (L,la(N),s(N))
c$$$      do 40  nchi=1,nchmi
         nqmi = npki(nchi+1) - npki(nchi)
c$$$         call   getchinfo2 (Nmaxi, lai, nchi, KJ, Ni, Li) 
c     call   getchinfo2 (nchi,Ni,KJ,temp,ener,lai,nai,Li) 
c     because of selection rule: Li=lf1,  Li can not be bigger then lomax
         if(Li.gt.lofmax) go to 40
c$$$         do 30  nchf=nchi,nchmf
            nqmf = npkf(nchf+1) - npkf(nchf)
c$$$            call   getchinfo2 (Nmaxf, laf, nchf, KJ, Nf, Lf)  
c     call   getchinfo2 (nchf,Nf,KJ,temp,ener,laf,naf,Lf) 
c     because of selection rule: 
            rK=KJ
            lli=lai(Ni)
            rLi=Li
            rlli=lli
            llf=laf(Nf)
            rLf=Lf
            rllf=llf
            lsi=si(Ni)
            lsf=sf(Nf)
            rsi=lsi
            rsf=lsf            
c$$$            if(abs(si(Ni)-0.5).gt.S.or.S.gt.si(Ni)+0.5) go to 40
c$$$            if(abs(sf(Nf)-0.5).gt.S.or.S.gt.sf(Nf)+0.5) go to 30
c     Ni,Nf  -   numbers of physical chanels
c     
c$$$            do ki=1,nqmi
c$$$               do i = 1, nr
c$$$                  chiform(i,ki) = 0.0
c$$$               enddo
c$$$               minchiform(ki) = nr
c$$$               maxchiform(ki) = 0
c$$$            enddo
            
c     Thise is a s.p. loop on s.p. functions of the coordinate r0
c            do 10  ni1=1,nspmi
            do 10  jni1=1,nam(Ni)
               ni1 = na(jni1,Ni)
               li1=loi(ni1)
               rli1=li1
c     these are 2 s.p. loops on s.p. functions of the coordinate r2
               do ki=1,nqmi
                  Ang2(ki) = 0.0
               end do
c               do 100 ni2=1,nspmi
               do 100 jni2=1,nam(Ni)
                  ni2 = na(jni2,Ni)
                  li2=loi(ni2)
                  rli2=li2
                  if(Ci(Ni,jni1,jni2).eq.0.0D0) go to 100     
c                  do nf2=1,nspmf
                  do jnf2=1,nam(Nf)
                     nf2 = na(jnf2,Nf)
                     lf2=lof(nf2)
                     rlf2=lf2
c     Thise is a s.p. loop on s.p. function of the coordinate r1
                     do ki=1,nqmi
                        Ang(ki) = 0.0
                     end do
                     ange0 = .true.
c                     do 20 nf1=1,nspmf
                     do 20 jnf1=1,nam(Nf)
                        nf1 = na(jnf1,Nf)
                        lf1=lof(nf1)
                        rlf1=lf1
c     Li=lf1 - this coordinate (r1) is not affected by V(r0,r2)       
                        if(Cf(Nf,jnf1,jnf2).eq.0d0.or.Li.ne.lf1)goto 20
                        Ang1 = hat(lli)*hat(llf)*hat(lsi)*hat(lsf)*
     >                     Cf(Nf,jnf1,jnf2)* Ci(Ni,jni1,jni2)*
     >                     COF6J(rLf,rlf2,rlli,rlf1,rK,rllf)*
c$$$     >                     COF6J(0.5,0.5,rsf,0.5,S,rsi)*
     >                     (-1)**(lf1+llf+Lf+lli+1-lsi+lsf)
                        Ang1el = 0.0
                        R2 = ortint(nf2,ni2)
                        if(Lf.eq.li1) then
                           Ang1el = Ci(Ni,jni1,jni2)*Cf(Nf,jnf1,jnf2)*
     >                        hat(lli)*hat(llf)*hat(lsi)*hat(lsf)*
     >                        (-1)**(li1+Li-lli+llf+1-lsi+lsf)*
c$$$     >                        COF6J(0.5,0.5,rsf,0.5,S,rsi)*
     >                        COF6J(rLi,rli2,rllf,rli1,rK,rlli)
                           do ki = 1, nqmi
                              kii = npki(nchi) + ki - 1
                              
c                              if(rrel(Li) .ne. 0.0) then
c                                 j1=max(minff(nf1),minci(kii))
c                                 j2=iCR
c                                 tmp_rel =  SUM(flf(j1:j2,nf1)*
c     >                              rrel(Li)*vrel(j1:j2)*
c     >                              chili(j1:j2,kii))
c                              else
c                                 tmp_rel = 0.0
c                              end if
                              
                              
                              R1 = ortchil(kii,nf1)
                              Ang2(ki) = Ang2(ki) + Ang1el *
     >                           (R1 * e1r(nf2,ni2) + R2 * (R1 *
     >                           gridk(ki,nchi)*abs(gridk(ki,nchi))/2.+
     >                           flchil(kii,nf1)
c     >                           + tmp_rel
     >                           ))
                           enddo                               
                        endif 
                        
                        do ki=1,nqmi
                           kii = npki(nchi) + ki - 1
                           R1 = ortchil(kii,nf1)
                           Ang(ki) = Ang(ki) + R1 * Ang1
                           ange0 = ange0 .and. Ang(ki) .eq. 0.0
                        end do
c     end nf1 loop
 20                  continue
                     lamtop=min(li1+Lf,lf2+li2,ltmax)
                     lambot=max(iabs(li1-Lf),iabs(lf2-li2))
                     do 140 lam=lambot,lamtop
                        rlam=lam
                        flam = fangint(lam,Lf,li1,lf2,li2,lli)
                        ange0 = ange0 .or. flam .eq. 0.0
                        if(.not.ange0) then
                           call getformout3(lam,flam,
     >                        fli(1,ni2),flf(1,nf2),minfi(ni2),
     >                        minff(nf2),maxfi(ni2),maxff(nf2),
     >                        fli(1,ni1),minfi(ni1),maxfi(ni1),
     >                        chiform,minchiform,maxchiform,
     >                        Ang,nqmi)
                        endif 
c     end lambda loop:
 140                 continue
c     end nf2 loop
                  end do
c     end ni2 loop
 100           continue 
c     Note: it is only true for ze=2, in other case you must  introduce
c     new array formout2(i) and later make overlap with |kfLf> separately.
               if (Lf.eq.li1) then
                  do ki=1,nqmi
                     Ang2(ki) = Ang2(ki) * (ze - 1.0)
                     do i=minchiform(ki),maxchiform(ki)
                        chiform(i,ki)=chiform(i,ki)+Ang2(ki)*flf(i,ni1)
                     end do
                  end do
               endif 
C     end ni1 loop
 10         continue
c$$$            TSpin = 0.5
c$$$            const = pnorm * ze 
c$$$     >         * COF6J(0.5,0.5,rsf,0.5,TSpin,rsi)
c$$$            TSpin = 1.5
c$$$            const2 = pnorm * ze 
c$$$     >         * COF6J(0.5,0.5,rsf,0.5,TSpin,rsi)
c$$$c$par doall            
c$$$            do ki = 1, nqmi
c$$$               kii = npki(nchi) + ki - 1
c$$$               do 90 kf = 1, nqmf
c$$$                  kff = npkf(nchf) + kf - 1
c$$$                  mini = max(minchiform(ki), mincf(kff))
c$$$                  if (kff.lt.kii.or.mini.gt.nr) go to 90
c$$$                  n = maxchiform(ki) - mini + 1
c$$$                  tmp = sdot(n,chilf(mini,kff),1,chiform(mini,ki),1)
c$$$                  VE2(kff,kii) = VE2(kff,kii) - const * tmp
c$$$                  if (lsi.eq.lsf.and.lsf.eq.1) 
c$$$     >               VE2(kii,kff+1)=VE2(kii,kff+1) - const2 * tmp
c$$$c     end ki,kf loops
c$$$ 90            continue 
c$$$            end do
c     end nchi,nchf loops
 30      continue       
 40   continue   
      return
      end
c*********************************************************************
c     this subroutine calculates matrix elements for V(r1,r2).
c     this subroutine is imilar to the ve2me that do the same for V(r0,r2)
      subroutine ve2me12(nchmi,Nmaxi,Ni,Li,lai,si,lpari,nspmi,loi,
     >   Ci,fli,maxfi,minfi,npki,chili,minci,
     >   nchmf,Nmaxf,Nf,Lf,laf,sf,lparf,nspmf,lof,
     >   Cf,flf,maxff,minff,npkf,chilf,mincf,ortint,ortchil,
     >   flchil,Etot,KJ,gridk,theta,inc,VEE,nchf,nchi,na,nam,namax)
      include 'par.f'
      double precision Z, fangint
      common /Zatom/ Z
      integer lai(Nmaxi), si(Nmaxi), lpari(Nmaxi)
      integer laf(Nmaxf), sf(Nmaxf), lparf(Nmaxf)
      double precision Ci(Nmaxi,namax,namax),Cf(Nmaxf,namax,namax),
     >   ortint(nspmax,nspmax), Etot
      dimension loi(nspmi), lof(nspmf),npki(nchmi+1), npkf(nchmf+1)
      dimension  fli(maxr,nspmax),maxfi(nspmi),minfi(nspmi)
      dimension  flf(maxr,nspmax),maxff(nspmf),minff(nspmf)
      dimension chili(nr,npki(nchmi+1)-1), minci(npki(nchmi+1)-1)
      dimension chilf(nr,npkf(nchmf+1)-1), mincf(npkf(nchmf+1)-1)
      dimension ortchil(npkf(nchmf+1)-1,nspmi),
     >   flchil(npkf(nchmf+1)-1,nspmi)
      double precision veT,hat,pnorm
      dimension  formout(maxr,kmax), minform(kmax),maxform(kmax)
      dimension  VEE(npkf(nchmf+1)-1,npki(nchmi+1)),
     >   Ang(kmax), Ang2(kmax)
      common /meshrr/ nr, gridr(nmaxr,3)
      dimension gridk(kmax,nchan)
      logical ange0             !, zeroc
      dimension na(nspmCI,KNM), nam(KNM)

c     Note : antisymmetrization is included through CI coefficients.
c     
      hat(l)=dsqrt(2.0*l+1.0D0)
      ze = 2.0
      pnorm = 2.0d0/dacos(-1.0d0)
c
c
c     Lf=li1, therefore  Lf  could not be bigger then lomax. It makes
c     limitations on value of KJ: |KJ-llf|<=Lf<=KJ+llf (0<=llf<=2*lomax),
c     hence maximum value of KJ is: (the same as in the routine ve2me())
      Ke2 = 3*lomax
      if(KJ.gt.Ke2)  return
      loimax = 0
      do ni1 = 1, nspmi
         loimax = max(loimax,loi(ni1))
      enddo
c     
c     These are 2 channels loops (nch = (L,ll(N),ls(N))
c     where L is projectile ang.mom., N is number of physical channel,
c     la(N),sa(N)  are  target ang. and spin mom..
c$$$      do  40  nchi = 1, nchmi
         nqmi = npki(nchi+1) - npki(nchi)
c$$$         call   getchinfo2 (Nmaxi,lai,nchi, KJ, Ni, Li) 
c     call   getchinfo2 (nchi,Ni,KJ,temp,ener,lai,nai,Li) 
c$$$         do  30  nchf = nchi, nchmf
            nqmf = npkf(nchf+1) - npkf(nchf)
c$$$            call   getchinfo2 (Nmaxf,laf,nchf, KJ, Nf, Lf)  
c     call   getchinfo2 (nchf,Nf,KJ,temp,ener,laf,naf,Lf) 
            if (Lf.gt.loimax) go to 30
            rK=KJ
            lli=lai(Ni)
            llf=laf(Nf)
            lsi=si(Ni)
            lsf=sf(Nf)
            rLi=Li
            rlli=lli
            rLf=Lf
            rllf=llf
            rsi=lsi
            rsf=lsf
c$$$            if(abs(si(Ni)-0.5).gt.S.or.S.gt.si(Ni)+0.5) go to 40
c$$$            if(abs(sf(Nf)-0.5).gt.S.or.S.gt.sf(Nf)+0.5) go to 30
c     Ni,Nf  -   numbers of physical chanels
c     
            do kf=1,nqmf
               do i = 1, nr
                  formout(i,kf) = 0.0
               enddo
               minform(kf) = nr
               maxform(kf) = 0
            enddo 
c     
c     these are 2 s.p. loops on s.p. functions of the coordinate r1 and r0
c            do 27 nf1=1,nspmf
            do 27 jnf1=1,nam(Nf)
               nf1 = na(jnf1,Nf)
               lf1=lof(nf1)
               rlf1=lf1
c     these are 2 s.p. loops on s.p. functions of the coordinate r1 and r2
               do kf=1,nqmf
                  Ang2(kf) = 0
               enddo 
c               do 10 nf2=1,nspmf
               do 10 jnf2=1,nam(Nf)
                  nf2 = na(jnf2,Nf)
                  if(Cf(Nf,jnf1,jnf2).eq.0.0D0)goto 10
                  lf2=lof(nf2)
                  rlf2=lf2
c                  do 20 ni2=1,nspmi
                  do 20 jni2=1,nam(Ni)
                     ni2 = na(jni2,Ni)
                     li2=loi(ni2)
                     rli2=li2
                     do kf=1,nqmf
                        Ang(kf) = 0
                     enddo
                     ange0 = .true.
c                     do 25 ni1=1,nspmi
                     do 25 jni1=1,nam(Ni)
                        ni1 = na(jni1,Ni)
                        li1=loi(ni1)
                        rli1=li1
                        if(Ci(Ni,jni1,jni2).eq.0d0.or.li1.ne.Lf)goto 25
                        Ang1 = Ci(Ni,jni1,jni2)*Cf(Nf,jnf1,jnf2)*
     >                     hat(lli)*hat(llf)*hat(lsi)*hat(lsf)*
     >                     (-1)**(li1+Li-lli+llf+1-lsi+lsf)*
     >                     COF6J(rLi,rli2,rllf,rli1,rK,rlli) 
c
c     remove instabilities in the frozen core model 
                        cth = 1.0
                        if(theta.ne.0.0) then
                           if(ni2.le.1)  cth = 1.0 - theta   ! FC model 
                           cth =  1.0 - theta  ! full CI model
                        else
c     remove nl-nl-nl components, due to the orthogonality of the ionic core
c     functions between itself and to the all other frozen-core-type orbitals
c     (nl)^3 case can occur only in this case:
c     ni1.eq.ni2.and.ni2.eq.nf1.and.nf1.eq.nf2
c     due to the <nf2|ni2> = \delta(nf2,ni2) if ni2 or nf2 belong to 
c     the ionic core. Therefore we can have 
                           if(ni1.eq.ni2.and.ni2.eq.nf1)cth =  -1.0
                        end if

c$$$  if (lsi.eq.1.and.nf1.eq.1) cth = 1.0
                        do kf = 1, nqmf
                           kff = npkf(nchf) + kf - 1
                           R0 = ortchil(kff,ni1)
                           Ang(kf) = Ang(kf) + R0 * Ang1
                           ange0 = ange0 .and. Ang(kf) .eq. 0.0
                           if (Li.eq.lf1) then
                              Ang2(kf) = Ang2(kf) + Ang1*(R0 *
     >                           (Etot * cth -
     >                           gridk(kf,nchf)*abs(gridk(kf,nchf))/2.)-
     >                           flchil(kff,ni1))*ortint(nf2,ni2)
                           endif 
                        enddo 
c     end ni1 loop
 25                  continue
c     target hamiltonian overlap
                     lammin = max(abs(lf1-Li),abs(lf2-li2))
                     lammax = min(lf1+Li,lf2+li2,ltmax)
                     do lam = lammin, lammax
                        flam = fangint(lam,lf1,Li,lf2,li2,llf) 
                        ange0 = ange0 .or. flam .eq. 0.0
                        if(.not.ange0) then
                           call getformout3(lam,flam,
     >                        fli(1,ni2),flf(1,nf2),minfi(ni2),
     >                        minff(nf2),maxfi(ni2),maxff(nf2),
     >                        flf(1,nf1),minff(nf1),maxff(nf1),
     >                        formout,minform,maxform,
     >                        Ang,nqmf)
                        end if
                     enddo 
c     end ni2,nf2 loops
 20               continue
 10            continue
               if (Li.eq.lf1) then
                  do kf = 1, nqmf
                     do i=minform(kf),maxform(kf)
                        formout(i,kf) = formout(i,kf) -
     >                     Ang2(kf) * flf(i,nf1)
                     end do
                  enddo
               endif 
c     end nf1 loop
 27         continue
            TSpin = 0.5
            const = pnorm * ze
     >         * COF6J(0.5,0.5,rsf,0.5,Tspin,rsi)
            TSpin = 1.5
            const2 = 0.0
            if (lsi.eq.lsf.and.lsf.eq.1) const2 = pnorm * ze
     >         * COF6J(0.5,0.5,rsf,0.5,Tspin,rsi)
c$$$c$par doall            
            do ki = 1, nqmi
               kii = npki(nchi) + ki - 1
               do 90 kf = 1, nqmf
                  kff = npkf(nchf) + kf - 1
                  mini = max(minci(kii),minform(kf))
                  n = maxform(kf) - mini + 1
                  if (kff.lt.kii.or.n.le.0) go to 90
                  veT = dot_product(chili(mini:maxform(kf),kii),
     >               formout(mini:maxform(kf),kf))
c$$$                  veT = sdot(n,chili(mini,kii),1,formout(mini,kf),1)
                  VEE(kff,kii) = VEE(kff,kii) - veT * const
                  VEE(kii,kff+1) = VEE(kii,kff+1) - veT * const2
c     end ki,kf loops
 90            continue 
            end do
C The following method of avoiding non-uniqueness is only correct for
C the orthogonal one-electron basis. Can use with full CI.

c method 1
            if (nchi.eq.nchf.and.Li.le.loimax.and.theta.ne.0.0) then
               const = theta * Etot * pnorm * ze
               do ni1 = 1, nspmi
                  nf1 = ni1
                  if (loi(ni1).eq.Li) then
                     do ki=npki(nchi), npki(nchi+1) - 1
                        ovlpi = ortchil(ki,ni1)
                        do 390 kf = npkf(nchf), npkf(nchf+1) - 1
                           if (kf.lt.ki) go to 390
                           ovlpf = ortchil(kf,nf1)
                           VEE(kf,ki) = VEE(kf,ki)-ovlpi*ovlpf*const
                           if (lsi.eq.lsf.and.lsf.eq.1) 
     >                        VEE(ki,kf+1) = VEE(ki,kf+1) -
     >                           ovlpi*ovlpf*const
c  end ki,kf loops
 390                    continue 
                     end do
                  endif
               enddo
            endif 
c method does not work for subset of f.c. states.

c     1) method works for frozen core model (with one core nsp=1)
c     with orthogonal s.p. functions and INC=0. In this case I_0 is biult
c     from these s.p. functions and all s.p. functions must be used CI program
c     Tipical errors: nonorthoganal set or use less functions in CI programm
c     then used in I_0
c     2) method works for frozen core model (with one core nsp=1), the set of 
c     s.p. functions can be nonorthogonal or nonnonorthogonal, and INC=1,
c     in this case I_0 projection operator is built from triplet f.c.o.
            if (Li.eq.Lf.and.lli.eq.llf.and.lsi.eq.lsf.
     >           and.Li.le.loimax-100.and.theta.ne.0.0) then
               const = theta * Etot * pnorm * ze
               const2 = 0.0
               if (lsf.eq.1) const2 = theta * Etot * pnorm * ze
c     do ni2 = 1,1    
               do jni2 = 1,nam(Ni)
                  ni2 = na(jni2,Ni)
                  if(ni2.eq.1) then
c     do ni1 = 1,nspmi
                  do jni1 = 1,nam(Ni)
                     ni1 = na(jni1,Ni)
c     do nf1 = 1,nspmf
                     do jnf1 = 1,nam(Nf)
                        nf1 = na(jnf1,Nf)
c     do nf2 = 1,nspmf
                        do jnf2 = 1,nam(Nf)
                           nf2 = na(jnf2,Nf)
                           tmp =  Ci(Ni,jni1,jni2)*Cf(Nf,jnf1,jnf2)*
     >                          ortint(nf1,ni1)*ortint(nf2,ni2)    
                           if (tmp.ne.0.0) then
                              do np = 1, nspmi
                                 if (loi(np).eq.Li) then
                          if (inc.eq.0.or.np.eq.1.or.si(np-1).eq.1) then
c     if (inc.eq.0.or.(np.eq.1.and.lsi.eq.0).or.
c     >                           si(np-1).eq.1) then
c$$$c$par doall                              
                             do ki=npki(nchi), npki(nchi+1) - 1
                                do 491 kf = npkf(nchf), npkf(nchf+1)-1
                                   if (kf.lt.ki) go to 491
                                   ovlpi = ortchil(ki,np)
                                   ovlpf = ortchil(kf,np) 
                                   VEE(kf,ki) = VEE(kf,ki) -
     >                                  tmp*ovlpi*ovlpf*const
                                   VEE(ki,kf+1) = VEE(ki,kf+1) -
     >                                  tmp*ovlpi*ovlpf*const2
c     end ki,kf loops
 491                            continue 
                             end do
                          end if	
                                 end if	
                              end do 
                           end if
                        end do
                     end do
                  end do
               end if   
               end do
            end if
c     method 2
c$$$c trying to build method that works on subset of f.c. states.
c$$$            if (Li.eq.Lf.and.lli.eq.llf.and.lsi.eq.lsf-10.
c$$$     >         and.Li.le.loimax.and.theta.ne.0.0.and.inc.ne.0) then
c$$$               const = theta * Etot * pnorm * ze
c$$$               do ni2 = 1,1
c$$$                  do ni1 = 1,nspmi
c$$$                     do nf1 = 1,nspmf
c$$$                        do nf2 = 1,nspmf
c$$$                  tmp =  Ci(Ni,ni1,ni2)*Cf(Nf,nf1,nf2)*ortint(nf1,ni1)*
c$$$     >               ortint(nf2,ni2)    
c$$$                  if (tmp.ne.0.0) then
c$$$                     do np0 = 1, Nmaxi
c$$$                        if (lai(np0).eq.Li) then
c$$$                           if (si(np0).eq.lsi) then
c$$$                              do ki=npki(nchi), npki(nchi+1) - 1
c$$$                                 do 490 kf = npkf(nchf), npkf(nchf+1)-1
c$$$                                    if (kf.lt.ki) go to 490
c$$$				    ovlpi = ortchil0(ki,np0)
c$$$				    ovlpf = ortchil0(kf,np0)
c$$$                                    VEE(kf,ki) = VEE(kf,ki) -
c$$$     >                                 tmp*ovlpi*ovlpf*const
c$$$                                    if (lsf.eq.1) 
c$$$     >                                 VEE(ki,kf+1) = VEE(ki,kf+1) -
c$$$     >                                 tmp*ovlpi*ovlpf*const
c$$$c     end ki,kf loops
c$$$ 490                             continue
c$$$                              end do
c$$$                           end if
c$$$                        end if	
c$$$                     end do 
c$$$                  end if
c$$$                        end do
c$$$                     end do
c$$$                  end do
c$$$               end do
c$$$            end if
c$$$C  The following uses the I_02 projection operator to ensure uniqueness
c$$$            if (theta.ne.0.0.and.Li.le.loimax-10.and.Lf.le.loimax) then
c$$$               const = theta * Etot * pnorm * ze
c$$$               nspm = nspmi
c$$$C  loop over the elements of the projection operator I_02
c$$$               do 67 Nn = 1, Nmaxi
c$$$                  ln = lai(Nn)
c$$$                  rln = ln
c$$$                  lsn = si(Nn)
c$$$                  rsn = lsn
c$$$                  do 200 nf2 = 1, nspm
c$$$                     if (zeroc(Cf,Nf,0,nf2,nspm)) go to 200
c$$$                     lf2=lof(nf2)
c$$$                     rlf2=lf2
c$$$                     do 210 ni2 = 1, nspm
c$$$                        if (zeroc(Ci,Ni,0,ni2,nspm)) go to 210
c$$$                        li2=loi(ni2)
c$$$                        rli2=li2
c$$$                        ovlp1 = 0.0
c$$$                        do 220 nf1 = 1, nspm
c$$$                           if (Cf(Nf,nf1,nf2).eq.0d0) go to 220
c$$$                           lf1=lof(nf1)
c$$$                           rlf1=lf1
c$$$                           do 230 ni1 = 1, nspm
c$$$                              if (Ci(Ni,ni1,ni2).eq.0d0) go to 230
c$$$                              li1=lof(ni1)
c$$$                              rli1=li1   
c$$$                              ovlp1=ovlp1+Cf(Nf,nf1,nf2)*Ci(Ni,ni1,ni2)
c$$$     >                           * ortint(nf1,ni1) *
c$$$     >                           COF6J(rLi,rli2,rln,rli1,rK,rlli)*
c$$$     >                           COF6J(rLf,rlf2,rln,rlf1,rK,rllf) *
c$$$     >                           (-1)**(Lf-llf+lf1+Li-lli+li1+lsi+lsf)
c$$$ 230                       continue 
c$$$ 220                    continue 
c$$$                        ovlp1 = ovlp1 * const *
c$$$c$$$     >                     COF6J(0.5,0.5,rsn,0.5,S,rsi) *
c$$$c$$$     >                     COF6J(0.5,0.5,rsn,0.5,S,rsf) *
c$$$     >                     (2.0 * rln + 1.0) * (2.0 * rsn + 1.0) *
c$$$     >                     hat(lli)*hat(llf)*hat(lsi)*hat(lsf)
c$$$                        
c$$$                        do ki = 1, nqmi
c$$$                           ang(ki) = 0.0
c$$$                           kii = npki(nchi) + ki - 1
c$$$                           do 100 nni1 = 1, nspm
c$$$                              if (loi(nni1).ne.Li) go to 100
c$$$                              ovlp2i = 0.0
c$$$                              do nni2 = 1, nspm
c$$$                                 ovlp2i  = ovlp2i + Ci(Nn,nni1,nni2)
c$$$     >                              * ortint(ni2,nni2)
c$$$                              enddo
c$$$                              ang(ki) = ang(ki) +
c$$$     >                           ovlp2i * ortchil(kii,nni1)
c$$$ 100                       continue
c$$$                        enddo 
c$$$                        do kf = 1, nqmf
c$$$                           ang2(kf) = 0.0
c$$$                           kff = npkf(nchf) + kf - 1
c$$$                           do 110 nnf1 = 1, nspm
c$$$                              if (lof(nnf1).ne.Lf) go to 110
c$$$                              ovlp2f = 0.0
c$$$                              do nnf2 = 1, nspm
c$$$                                 ovlp2f  = ovlp2f + Cf(Nn,nnf1,nnf2)
c$$$     >                              * ortint(nf2,nnf2)
c$$$                              enddo
c$$$                              ang2(kf) = ang2(kf) +
c$$$     >                           ovlp2f * ortchil(kff,nnf1)
c$$$ 110                       continue
c$$$                        enddo
c$$$                        TSpin = 0.5
c$$$                        ovlp2 = ovlp1 *
c$$$     >                     COF6J(0.5,0.5,rsn,0.5,TSpin,rsi) *
c$$$     >                     COF6J(0.5,0.5,rsn,0.5,Tspin,rsf) 
c$$$                        TSpin = 1.5
c$$$                        ovlp3 = ovlp1 *
c$$$     >                     COF6J(0.5,0.5,rsn,0.5,TSpin,rsi) *
c$$$     >                     COF6J(0.5,0.5,rsn,0.5,Tspin,rsf) 
c$$$                                 
c$$$                        do ki = 1, nqmi
c$$$                           kii = npki(nchi) + ki - 1
c$$$                           do 190 kf = 1, nqmf
c$$$                              kff = npkf(nchf) + kf - 1
c$$$                              if (kff.lt.kii) go to 190
c$$$                              VEE(kff,kii) = VEE(kff,kii) -
c$$$     >                           ang(ki) * ang2(kf) * ovlp2
c$$$                              if (lsi.eq.lsf.and.lsf.eq.1) 
c$$$     >                           VEE(kii,kff+1) = VEE(kii,kff+1) -
c$$$     >                           ang(ki) * ang2(kf) * ovlp3
c$$$c     end ki,kf loops
c$$$ 190                       continue
c$$$                        enddo
c$$$C  End the nf2 and ni2 loops
c$$$ 210                 continue 
c$$$ 200              continue 
c$$$C  End the Nn loop over the projection operator states
c$$$ 67            continue
c$$$            endif 
c
c     end nchi,nchf loops
 30      continue       
 40   continue       
      return
      end         
c*******************************************************************
c$$$      function zeroc(C,N,nn1,nn2,nspm)
c$$$      include 'par.f'
c$$$      double precision C(KNM,nspmax,nspmax)
c$$$      logical zeroc
c$$$      zeroc = .true.
c$$$      if (nn1.eq.0) then
c$$$         n2 = nn2
c$$$         do n1 = 1, nspm
c$$$            zeroc = zeroc .and. C(N,n1,n2).eq.0.0D0
c$$$         enddo
c$$$      else
c$$$         n1 = nn1
c$$$         do n2 = 1, nspm
c$$$            zeroc = zeroc .and. C(N,n1,n2).eq.0.0D0
c$$$         enddo
c$$$      endif
c$$$      return
c$$$      end
         
c*******************************************************************
c     This routine is called only from the direct ME routine vdme(...)
      subroutine getformout(lam,Vang,upot,fli,flf,minfi,minff,
     >    maxfi,maxff,maxni1,torf,formout,minform,maxform)
       include 'par.f'
       common /meshrr/ nr, gridr(maxr,3)
       dimension  fli(maxr), flf(maxr)
       dimension temp(maxr), fun(maxr), upot(maxr), formout(maxr)
       common/powers/ rpow1(maxr,0:ltmax),rpow2(maxr,0:ltmax),
     >    minrp(0:ltmax),maxrp(0:ltmax),cntfug(maxr,0:lmax)
       logical torf
C the following is not used in the nuclear routine
       data nznuc/2/
       common /di_el_core_polarization/ gamma, r0, pol(nmaxr)
       
       minfun=max(minfi,minff)
       maxfun=min(maxfi,maxff)
       do i=minfun,maxfun
          fun(i) = fli(i) * flf(i) * gridr(i,3)
       end do

       call form(fun,minfun,maxfun,rpow1(1,lam),rpow2(1,lam),
     >    minrp(lam),maxrp(lam),maxni1,temp,i1,i2)
c     if this is diagonal ME then for lambda = 0  do subtraction of the nuclear term
       if (lam.eq.0.and.torf) call nuclear(fun,.true.,minfun,maxfun,i2,
     >      upot,nznuc,temp)

       if(lam.eq.1.and.gamma.ne.0.0) then
          sum1 = 0.0
          do i=minfun,maxfun
             sum1 = sum1 + fun(i)*pol(i)
          end do                       
          tmp = gamma * sum1 
          do i=i1,i2             
             temp(i) = temp(i) - tmp*pol(i)
          end do
       end if
       
       do i = i1, i2
          formout(i) = formout(i) + temp(i) * Vang
       enddo 
       minform = min(minform,i1)
       maxform = max(maxform,i2)
       return
       end
c*******************************************************************
c     This routine is called only from the exchange ME routine ve1me(...)
      subroutine getformout2(lam,fli,flf,minfi,minff,
     >    maxfi,maxff,maxni1,formout,minform,maxform)
       include 'par.f'
       common /meshrr/ nr, gridr(maxr,3)
       dimension  fli(maxr), flf(maxr)
       dimension  fun(maxr), formout(maxr)
       common/powers/ rpow1(maxr,0:ltmax),rpow2(maxr,0:ltmax),
     >    minrp(0:ltmax),maxrp(0:ltmax),cntfug(maxr,0:lmax)
       common /di_el_core_polarization/ gamma, r0, pol(nmaxr)
       
       minfun=max(minfi,minff)
       maxfun=min(maxfi,maxff)

       do i=minfun,maxfun
          fun(i) = fli(i) * flf(i)
       end do

       call form(fun,minfun,maxfun,rpow1(1,lam),rpow2(1,lam),
     >    minrp(lam),maxrp(lam),maxni1,formout,i1,i2)

       if(lam.eq.1.and.gamma.ne.0.0) then
          sum1 = 0.0
          do i=minfun,maxfun
             sum1 = sum1 + fun(i)*pol(i)
          end do                       
          tmp = gamma*sum1
          do i=i1,i2             
             formout(i) = formout(i) - tmp*pol(i)
          end do
       end if
       
       minform = i1
       maxform = i2
       return
       end
c************************************************************************
       subroutine getformout3(lam,flam,fli,flf,minfi,minff,
     >    maxfi,maxff,fl,minfl,maxfl,formout,minform,maxform,
     >    Ang,nqm)
       include 'par.f'
       common /meshrr/ nr, gridr(maxr,3)
       dimension  fli(maxr), flf(maxr), fl(maxr)
       dimension   Ang(kmax), minform(kmax), maxform(kmax)
       dimension temp(maxr), fun(maxr), formout(maxr,kmax)
       common/powers/ rpow1(maxr,0:ltmax),rpow2(maxr,0:ltmax),
     >    minrp(0:ltmax),maxrp(0:ltmax),cntfug(maxr,0:lmax)
       common /di_el_core_polarization/ gamma, r0, pol(nmaxr)
        
       minfun=max(minfi,minff)
       maxfun=min(maxfi,maxff)
       do i=minfun,maxfun
          fun(i) = fli(i) * flf(i) * gridr(i,3)
       end do
       call form(fun,minfun,maxfun,rpow1(1,lam),rpow2(1,lam),
     >    minrp(lam),maxrp(lam),maxfl,temp,i1,i2)

       if(lam.eq.1.and.gamma.ne.0.0) then
          sum1 = 0d0
          do i=minfun,maxfun
             dr = gridr(i,3)
             sum1 = sum1 + fun(i)*pol(i)
          end do
          tmp = gamma * sum1
          do i=i1,maxfl      
              temp(i) = temp(i) - tmp*pol(i)
          end do
       end if

       i1 = max(i1,minfl)
       i2 = min(i2,maxfl)
       do k=1,nqm
          const = Ang(k)*flam
          do i = i1, i2
             formout(i,k)=formout(i,k) + const * temp(i)*fl(i)
          enddo 
          minform(k) = min(minform(k),i1)
          maxform(k) = max(maxform(k),i2)
       enddo 
       return
       end
c************************************************************************
      subroutine getchinfo2 (Nmax,la,nch, KJ, N, lp)
      dimension la(Nmax)
      ncht = 0
      do N=1,Nmax
         do  lp = abs(KJ-la(N)), KJ+la(N)
            Kpar=(-1)**(KJ)
            lpar=(-1)**(lp+la(N))
            if(Kpar.eq.lpar) then
               ncht = ncht + 1
            end if
            if (nch.eq.ncht) return
         end do
      end do
      return
      end
