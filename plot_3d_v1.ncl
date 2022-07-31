
	load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
	load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
	load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

	begin
	

	  dir      	= "./"
	  fn 		= "wrfout_d01_2016-10-06_00%3A00%3A00"
	  a 		= addfile(dir + fn + ".nc","r")
	  var 		= getfilevarnames(a)
	   ; print(var)
	   ; exit
      ; p  		= wrf_user_getvar(a, "pressure",-1)
	  ; printVarSummary(p)
	  ; printMinMax(p,-1)
	  ;exit
	  ; print(var)
	  ; exit 
	  
	  ; time		= wrf_user_getvar(a, "times", -1)
      ; ;print(time)
      ; time		:=cd_inv_string(time, "%Y-%N-%D_%H:00:00")
      ; ; printVarSummary(time)
	  ; ; exit
	  
	  lat2d  		= wrf_user_getvar(a, "XLAT",-1)    ; 15-39
	  lon2d  		= wrf_user_getvar(a, "XLONG",-1)   ; -87 - -62
	  printVarSummary(lat2d)
	  printVarSummary(lon2d)
	 

		; times  	= wrf_user_list_times(a)  ; get times in the file
		; ntimes 	= dimsizes(times)         ; number of times in the file
      
	  time 		= -1
	  
	  ; u_in   = wrf_user_getvar(a,"U",time)    
	  ; v_in   = wrf_user_getvar(a,"V",time)    
	  u_in   = wrf_user_getvar(a,"ua",time)    ; ua is u averaged to mass points
	  v_in   = wrf_user_getvar(a,"va",time)    ; va is v averaged to mass points
	  w_in   = wrf_user_getvar(a,"wa",time)    ; vertical velocity
	  t_in  	= wrf_user_getvar(a,"tk",time)    ; get temperature (C)
	  z_in   	= wrf_user_getvar(a, "z",time)    ; grid point height
	  ; ter    = wrf_user_getvar(a,"HGT",time)   ; need terrain height sometimes
      
	  w_in 		= 500.0*w_in
	  
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
	  
	  u   	=  u_in
	  v   	=  v_in
	  w   	=  w_in
	  t  	=  t_in
	  z   	=  z_in

	

      p   		= (/1000,900,850,750,600,500,400,300,200,150,100/)
	  ;p!0 		= "pressure"
	  p@units  	= "hPa"
	  u_plane  	= wrf_user_interp_level(u,z,p,False)
	  v_plane  	= wrf_user_interp_level(v,z,p,False)
	  w_plane  	= wrf_user_interp_level(w,z,p,False)
	  t_plane  	= wrf_user_interp_level(t,z,p,False)
	  
	  ; u_plane  	= wrf_user_intrp3d( u,z,"v",plane,angle,False)
	  ; v_plane  	= wrf_user_intrp3d( v,z,"v",plane,angle,False)
	  ; w_plane  	= wrf_user_intrp3d( w,z,"v",plane,angle,False)
	  ; th_plane 	= wrf_user_intrp3d(th,z,"v",plane,angle,False)
	  
	  u_plane&south_north  	= lat2d(0,:,0)
	  u_plane&west_east  	= lon2d(0,0,:)
	  
	  copy_VarCoords(u_plane,v_plane)
	  copy_VarCoords(u_plane,w_plane)
	  copy_VarCoords(u_plane,t_plane)
	  
	  printVarSummary(u_plane)
	  printVarSummary(v_plane)
	  printVarSummary(t_plane)
	  printMinMax(t_plane,-1)
	  printMinMax(v_plane,-1)
	  printMinMax(w_plane,-1)
	  
	  ;exit

	  ; vel_normal  = u_plane*cos(2.*pii*angle/360.) - v_plane*sin(2.*pii*angle/360.)
	  ; vel_tangent = u_plane*sin(2.*pii*angle/360.) + v_plane*cos(2.*pii*angle/360.)
	  ; vel_tangent = vel_tangent - 10.
	  
	  lon1 		= -85
	  lon2		= -65
	  
	  u_m 		= dim_avg_n_Wrap(u_plane(:,:,{lon1:lon2}),2)
	  v_m 		= dim_avg_n_Wrap(v_plane(:,:,{lon1:lon2}),2)
      w_m 		= dim_avg_n_Wrap(w_plane(:,:,{lon1:lon2}),2)
      t_m 		= dim_avg_n_Wrap(t_plane(:,:,{lon1:lon2}),2)
	  printVarSummary(u_m)
	  printMinMax(u_m,-1)
	  
	  ;exit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	

	wks 		= gsn_open_wks("x11","plt_3d_tem_uv")
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
    
	;res@cnLineDrawOrder 		= "PostDraw"
	
    res@tmYRMode 				= "Automatic"
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
	
	
	 res@gsnLeftStringFontHeightF 		= 0.03
	 res@gsnRightStringFontHeightF 	= 0.015
	 res@gsnRightString 				= " "
   
	  
	 res@vcRefAnnoString2On 			= False
	 res@vcRefAnnoFontHeightF 			= 0.05
	 res@vcRefAnnoSide 					= "Right"
	 res@vcLineArrowThicknessF 		= 2.0
	   
	 res@vcMinDistanceF 				= 0.015	 
	 res@vcRefLengthF    				= 0.05		
		
	 res@vcMinMagnitudeF				= 0.1   
	 res@vcRefMagnitudeF 				= 2.
   
	   res@cnLevels  		= 280.0 + (/1,2,3,4,5,6,7,8,9,10/)*2.0
	   res@gsnLeftString 	= "test: Temperature "
	 
		
	   plot(0)          	= gsn_csm_pres_hgt_vector(wks,t_m,v_m,w_m,res)
	   plot(1)          	= gsn_csm_pres_hgt(wks,t_m,res)
		
  
		; pltres = True

	 ; ; Theta
		  ; opts_th  = res
		  ; opts_th@FieldTitle           = th_in@description
		  ; opts_th@cnFillOn             = True
		  ; opts_th@PlotOrientation      = th_plane@Orientation
		  ; contour_th     = wrf_contour(a,wks,th_plane,opts_th)

	 ; ; Vertical Velocity
		  ; opts_w   = res
		  ; opts_w@FieldTitle            = w_in@description
		  ; contour_w = wrf_contour(a,wks, w_plane,opts_w)

	 ; ; Vel Tangent
		  ; opts_vt   = res
		  ; opts_vt@FieldTitle           = "Perturbation u"
		  ; opts_vt@UnitLabel            = "m/s"
		  ; contour_vt     = wrf_contour(a,wks,vel_tangent,opts_vt)


		  ; plot = wrf_overlays(a,wks,(/contour_th, contour_vt/),pltres)
		  ; plot = wrf_overlays(a,wks,(/contour_th, contour_w/),pltres)

	  ;       ************************************************************
	  
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
	
	
	resp@txString = "Test: Tem & vw over (85-65W)"
	
	resp@txFontHeightF = 0.015
	gsn_panel(wks,plot,(/2,1/),resp)

	end
	