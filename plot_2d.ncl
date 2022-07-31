
	load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
	load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
	load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

	begin
	

	  dir      		= "./"
	  fn 			= "wrfout_d01_2016-10-06_00%3A00%3A00"
	  a 			= addfile(dir + fn + ".nc","r")
	  
	  
	  lat2d  		= wrf_user_getvar(a, "XLAT",-1)    ; 15-39
	  lon2d  		= wrf_user_getvar(a, "XLONG",-1)   ; -87 - -62
	  printVarSummary(lat2d)
	  printVarSummary(lon2d)
	 
	  time 		= -1
	  
	  
	  u_in   	= wrf_user_getvar(a,"ua",time)    ; ua is u averaged to mass points
	  v_in   	= wrf_user_getvar(a,"va",time)    ; va is v averaged to mass points
	  ;w_in   	= wrf_user_getvar(a,"wa",time)    	; vertical velocity
	  t_in  	= wrf_user_getvar(a,"tk",time)    ; get temperature (K)
	  z_in   	= wrf_user_getvar(a, "z",time)    ; grid point height
	  
	  u_in&south_north  = lat2d(0,:,0)
	  u_in&west_east  	= lon2d(0,0,:)
	 
	  printVarSummary(u_in)
      copy_VarCoords(u_in,v_in)
	  copy_VarCoords(u_in,t_in)
	  copy_VarCoords(u_in,z_in)
	  
	  printMinMax(u_in,-1)
	  printMinMax(v_in,-1)
	  printMinMax(z_in,-1)
	  printMinMax(t_in,-1)
	  ;exit
     ; printVarSummary(ter)
      ;exit
	  ; u   	=  u_in(0,0:34,:,:)
	  ; v   	=  v_in(0,0:34,:,:)
	  ; w   	=  w_in(0,0:34,:,:)
	  ; th  	=  th_in(0,0:34,:,:)
	  ; z   	=  z_in(0,0:34,:,:)
	  
	  u   		=  u_in
	  v   		=  v_in
	  ;w   	=  w_in
	  t  		=  t_in
	  z   		=  z_in
	  
      ; p   		= (/1000,900,850,750,600,500,400,300,200,150,100/)
	  ; ;p!0 		= "pressure"
	  ; p@units  	= "hPa"
	  ; u_plane  	= wrf_user_interp_level(u,z,p,False)
	  ; v_plane  	= wrf_user_interp_level(v,z,p,False)
	  ; ;w_plane  	= wrf_user_interp_level(w,z,p,False)
	  ; t_plane  	= wrf_user_interp_level(t,z,p,False)
	  
	  plev   		= 850
	  plev@units  		= "hPa"
	  u_plane  		= wrf_user_interp_level(u,z,plev,False)
	  v_plane  		= wrf_user_interp_level(v,z,plev,False)
	  ;w_plane  	= wrf_user_interp_level(w,z,p,False)
	  t_plane  		= wrf_user_interp_level(t,z,plev,False)
	  
	  u_plane&south_north  	= lat2d(0,:,0)
	  u_plane&west_east  	= lon2d(0,0,:)
	  
	  copy_VarCoords(u_plane,v_plane)
	 ; copy_VarCoords(u_plane,w_plane)
	  copy_VarCoords(u_plane,t_plane)
	  
	  printVarSummary(u_plane)
	  printVarSummary(v_plane)
	  printVarSummary(t_plane)
	  printMinMax(t_plane,-1)
	  printMinMax(v_plane,-1)
	  ;printMinMax(w_plane,-1)
	  
	  ;exit

	 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	latSt			= 15
	latLt			= 35
	lonSt			= -85
    lonLt 			= -65
	
	wks 		= gsn_open_wks("x11","plt_2d_tem_uv_"+plev)
	gsn_define_colormap(wks,"temp_diff_18lev")
	  
	plot		= new(2,graphic)

	res 						= True
    res@gsnDraw 				= False
	res@gsnFrame 				= False
	res@gsnAddCyclic 			= False
	res@gsnMaximize				= False

	res@cnInfoLabelOn         	= False
	res@cnFillOn              	= True            ; turn on color for contours
	res@cnLinesOn            	= False              ; turn off contour lines
	res@cnLineLabelsOn       	= False              ; turn off contour line labels
   
  
	  res@mpFillOn             = False        
	  res@mpMinLatF            = latSt         
	  res@mpMaxLatF            = latLt
	  res@mpMinLonF            = lonSt
	  res@mpMaxLonF            = lonLt
	  res@mpCenterLonF			= (lonLt+lonSt)/2
	  
	res@mpGeophysicalLineColor 	= "gray40"
	res@mpGeophysicalLineThicknessF= 1.0
	
	
	res@tmXTOn    				= False
	res@tmYROn    				= False
	res@tmXBLabelFontHeightF 	= 0.025
	res@tmYLLabelFontHeightF 	= 0.025
	;res@tmXBTickSpacingF  		= 10
	; res@tmYLTickSpacingF  		= 15
    res@tiYAxisOn 				= False
	res@gsnSpreadColors 		= True
	

	;res@pmLabelBarOrthogonalPosF   = -0.2
	res@lbLabelFontHeightF       	= 0.02
	res@lbLabelBarOn             	= True
	res@lbBoxLinesOn             	= False
	;res@pmLabelBarHeightF 			= 0.1
	
		
	 res@cnLevelSelectionMode 			= "ExplicitLevels"
	 res@cnFillColors      				= (/4,5,7,8,9,10,12,13,14,15,17,18/)
	 res@cnLevels  						= 280.0 + (/1,2,3,4,5,6,7,8,9,10/)*2.0
	 
	 
	
	 res@gsnLeftStringFontHeightF 		= 0.03
	 res@gsnRightStringFontHeightF 	= 0.015
	 res@gsnRightString 				= " "
     
	
	 res@gsnLeftString 					= "(a) Tem&UV at "+ plev +" mb"	
	   plot(0)          				= gsn_csm_contour_map(wks,t_plane,res)
	   
		
    delete([/res@mpCenterLonF,res@mpMaxLatF,res@mpMinLatF,res@mpMaxLonF,res@mpMinLonF,\
	      res@mpGeophysicalLineColor,res@mpGeophysicalLineThicknessF,res@cnFillColors,res@cnLevels/])
	; delete(res@mpMaxLatF)
	; delete(res@mpMinLatF)
	; delete(res@mpMaxLonF)
	; delete(res@mpMinLonF)
	; delete(res@mpGeophysicalLineColor)
	; delete(res@mpGeophysicalLineThicknessF)
	; delete(res@cnFillColors )
	; delete(res@cnLevels)
	

	
	
	
       vres 							= True
	   vres@gsnFrame 					= False
	   vres@gsnDraw						= False
	   
	   vres@vcRefAnnoString2On 		= False
	   vres@vcRefAnnoFontHeightF 		= 0.015
	   vres@vcRefAnnoSide 				= "Right"
	   vres@vcLineArrowThicknessF 		= 1.0
	   
	   vres@vcMinDistanceF 			= 0.015
	   vres@vcRefLengthF    			= 0.05
	   
	
	   vres@vcRefMagnitudeF 			= 5.0  
	   vres@vcMinMagnitudeF			= 0.5
	   
	   vres@vcLineArrowThicknessF 		= 1.0
	   vres@vcLineArrowColor		 	= "black"
	   vres@gsnLeftString				= " "
	   
	   plot0         	= gsn_csm_vector(wks,u_plane,v_plane,vres)	  
	   overlay(plot(0),plot0)	

       
	   
	  ; ************************************************************
	  
	  resp              				= True
	  resp@gsnPanelRowSpec 			= True
	resp@gsnPanelCenter  			= False
	;resp@gsnPanelTop     = 0.99
	resp@gsnPanelBottom  			= 0.1
	resp@gsnPanelLabelBar 			= False
	resp@lbBoxLinesOn     			= False
	resp@lbLabelFontHeightF 		= 0.015
	resp@pmLabelBarHeightF 		= 0.06
	resp@gsnPanelXWhiteSpacePercent = 3
	resp@gsnPanelYWhiteSpacePercent = 3
	
	
	resp@txString = "Test: Tem & vw at "+plev+"mb"
	
	resp@txFontHeightF = 0.015
	gsn_panel(wks,plot,(/2,1/),resp)

	end
	