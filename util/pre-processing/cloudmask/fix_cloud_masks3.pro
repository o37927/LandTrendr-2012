pro fix_cloud_masks3, image_info_savefile, fix_cloudmasks, fixmask=fixmask, from_madcal=from_madcal, ledaps=ledaps

  if keyword_set(from_madcal) eq 1 then goto, single_date_from_madcal
  restore, image_info_savefile
  
  ;check for dates that don't have a cloudmask
  nomask = where(image_info.cloud_file eq 'none', n_nomask)
  if n_nomask ge 1 then nomask = image_info[nomask].image_file
  
  ;check for fix dates
  if keyword_set(fixmask) eq 1 then begin
    fixthese = strarr(n_elements(fixmask))
    for i=0, n_elements(fixmask)-1 do begin
      fixthis = strcompress(string(fixmask[i]), /rem)
      year = strmid(fixthis, 0, 4)
      doy = strmid(fixthis, 4, 3)
      fixthis = strcompress("*"+year+"_"+doy+"*", /rem)
      imgmatch = strmatch(image_info.image_file, fixthis)
      thisone = where(imgmatch eq 1, n_thisone)
      if n_thisone eq 1 then fixthese[i] = image_info[thisone].image_file
      if n_thisone gt 1 then begin
        print, "there is more than one match for the cloud fix"
        print, "there can be only one"
        print, image_info[thisone].image_file
        return
      endif
      if n_thisone eq 0 then begin
        print, "there is no match for fixing"
        print, "check this file"
        print, fixmask[i]
        return
      endif
    endfor
  endif
  
  ;fill in the full list of images to fix cloudmask for
  if n_nomask ge 1 and keyword_set(fixmask) eq 1 then begin
    dothese = [nomask,fixthese]
    if n_nomask ge 2 then printthis = transpose(nomask) else printthis = nomask
    print, ""
    print, ">>> there are dates that are missing cloudmasks:"
    print, printthis
    print, ">>> fixing these before doing the requested fixes"
    print, ""
  endif
  if n_nomask ge 1 and keyword_set(fixmask) eq 0 then begin
    dothese = nomask
    print, ""
    print, ">>> there are dates that are missing cloudmasks:"
    print, "    ",nomask
    print, ""
  endif
  if n_nomask eq 0 and keyword_set(fixmask) eq 1 then dothese = fixthese
  
  single_date_from_madcal:
  if keyword_set(from_madcal) eq 1 then dothese = from_madcal
  
  ;fix the makes
  for i=0, n_elements(dothese)-1 do begin
    imgmatch = dothese[i]
    if fix_cloudmasks eq 1 then cloud_masking_gui, imgmatch, ledaps=ledaps
    if fix_cloudmasks eq 2 then cloud_masking_gui_img_dif, imgmatch, ledaps=ledaps
  endfor
end    
    
