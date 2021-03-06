--[[	Instructions

 Position: 'Align X' means all selected \pos tags will have the same given X coordinate. Same with 'Align Y' for Y.
   useful for multiple signs on screen that need to be aligned horizontally/vertically or mocha signs that should move horizontally/vertically.
   'align with first' uses X or Y from the first line.
   
 Move: 'horizontal' means y2 will be the same as y1 so that the sign moves in a straight horizontal manner. Same principle for 'vertical.'
 Transmove: this is the real deal here. Main function: create \move from two lines with \pos.
	Duplicate your line and position the second one where you want the \move the end. Script will create \move from the two positions.
	Second line will be deleted by default; it's there just so you can comfortably set the final position.
	Extra function: to make this a lot more awesome, this can create transforms.
	Not only is the second line used for \move coordinates, but also for transforms. 
	Any tag on line 2 that's different from line 1 will be used to create a transform on line 1.
	So for a \move with transforms you can set the initial sign and then the final sign while everything is static.
	You can time line 2 to just the last frame. The script only uses timecodes from line 1. 
	Text from line 2 is also ignored (assumed to be same as line 1).
	You can time line 2 to start after line 1 and check 'keep both.' 
	That way line 1 transforms into line 2 and the sign stays like that for the duration of line 2.
	'Rotation acceleration' - like with fbf-transform, this ensures that transforms of rotations will go the shortest way,
	thus going only 4 degrees from 358 to 2 and not 356 degrees around.
	If the \pos is the same on both lines, only transforms will be applied.
	Logically, you must NOT select 2 consecutive lines when you want to run this, though you can select every other line.
 Multimove: when first line has \move and the other lines have \pos, \move is calculated from the first line for the others.
 Shiftmove: like teleporter, but only for the 2nd set of coordinates, ie x2, y2. Uses input from the Teleporter section.
 
 Modifications: 'round numbers' rounds coordinates for pos, move, org and clip depending on the 'Round' submenu.
   'reverse move' reverses the direction of \move.
   
 Copy Coordinates: copies from first line to the others.
 
 Teleport: shifts coordinates by given X and Y values.
   
--]]


--	SETTINGS	--

align_with_first=false
keep_both=false
rotation_acceleration=true

cc_posimove=true
cc_org=true
cc_clip=true
cc_tclip=true
cc_replicate_tags=true

tele_pos=true
tele_move=true
tele_clip=true
tele_org=true

--  --	--  --	--  --	--

script_name = "Hyperdimensional Relocator"
script_description = "Makes things appear different from before"
script_author = "reanimated"
script_version = "1.1"

function positron(subs,sel)
    ps=res.post
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	    if x==1 and not text:match("\\pos") then aegisub.dialog.display({{class="label",
		    label="No \\pos tag in the first line.",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()  end
		    
	    if x==1 and res.first then pxx,pyy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") 
		if res.posi=="Align X" then ps=pxx else ps=pyy end 
	    end
	    
	    if text:match("\\pos") then
		if res.posi=="Align X" then
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos("..ps..",%2)")
		else
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos(%1,"..ps..")")
		end
	    end
	line.text=text
        subs[i] = line
    end
end

function bilocator(subs, sel)
    for i=#sel,1,-1 do
        local line = subs[sel[i]]
	local text=line.text
	
	    if res.move=="transmove" and sel[i]<#subs then
	    
	    	start=line.start_time		-- start time
		endt=line.end_time		-- end time
		nextline=subs[sel[i]+1]
		text2=nextline.text
		
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		
		keyframes=aegisub.keyframes()	-- keyframes table
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		start2=fr2ms(startf)
		endt2=fr2ms(endf-1)
		tim=fr2ms(1)
		movt1=start2-start+tim		-- first timecode in \move
		movt2=endt2-start+tim		-- second timecode in \move
		movt=movt1..","..movt2
		
		-- failcheck
		if not text:match("\\pos") or not text2:match("\\pos") then 
		aegisub.dialog.display({{class="label",label="Missing \\pos tags.",x=0,y=0,width=1,height=2}},{"OK"}) 
		aegisub.cancel()
		end
		
		-- move
		p1=text:match("\\pos%(([^%)]+)%)")
		p2=text2:match("\\pos%(([^%)]+)%)")
		if p2~=p1 then text=text:gsub("\\pos%(([^%)]+)%)","\\move(%1,"..p2..","..movt..")") end
		
		-- transforms
		tf=""
		
		-- fstuff
		if text2:match("\\fs[%d%.]+") then fs2=text2:match("(\\fs[%d%.]+)") 
		    if text:match("\\fs[%d%.]+") then fs1=text:match("(\\fs[%d%.]+)") else fs1="" end
		    if fs1~=fs2 then tf=tf..fs2 end
		end
		if text2:match("\\fsp[%d%.%-]+") then fsp2=text2:match("(\\fsp[%d%.%-]+)") 
		    if text:match("\\fsp[%d%.%-]+") then fsp1=text:match("(\\fsp[%d%.%-]+)") else fsp1="" end
		    if fsp1~=fsp2 then tf=tf..fsp2 end
		end
		if text2:match("\\fscx[%d%.]+") then fscx2=text2:match("(\\fscx[%d%.]+)") 
		    if text:match("\\fscx[%d%.]+") then fscx1=text:match("(\\fscx[%d%.]+)") else fscx1="" end
		    if fscx1~=fscx2 then tf=tf..fscx2 end
		end
		if text2:match("\\fscy[%d%.]+") then fscy2=text2:match("(\\fscy[%d%.]+)") 
		    if text:match("\\fscy[%d%.]+") then fscy1=text:match("(\\fscy[%d%.]+)") else fscy1="" end
		    if fscy1~=fscy2 then tf=tf..fscy2 end
		end
		-- blur border shadow
		if text2:match("\\blur[%d%.]+") then blur2=text2:match("(\\blur[%d%.]+)") 
		    if text:match("\\blur[%d%.]+") then blur1=text:match("(\\blur[%d%.]+)") else blur1="" end
		    if blur1~=blur2 then tf=tf..blur2 end		
		end
		if text2:match("\\bord[%d%.]+") then bord2=text2:match("(\\bord[%d%.]+)") 
		    if text:match("\\bord[%d%.]+") then bord1=text:match("(\\bord[%d%.]+)") else bord1="" end
		    if bord1~=bord2 then tf=tf..bord2 end
		end
		if text2:match("\\shad[%d%.]+") then shad2=text2:match("(\\shad[%d%.]+)") 
		    if text:match("\\shad[%d%.]+") then shad1=text:match("(\\shad[%d%.]+)") else shad1="" end
		    if shad1~=shad2 then tf=tf..shad2 end
		end
		-- colours
		if text2:match("\\1?c&H%x+&") then c12=text2:match("(\\1?c&H%x+&)") 
		    if text:match("\\1?c&H%x+&") then c11=text:match("(\\1?c&H%x+&)") else c11="" end
		    if c11~=c12 then tf=tf..c12 end
		end
		if text2:match("\\2c&H%x+&") then c22=text2:match("(\\2c&H%x+&)") 
		    if text:match("\\2c&H%x+&") then c21=text:match("(\\2c&H%x+&)") else c21="" end
		    if c21~=c22 then tf=tf..c22 end
		end
		if text2:match("\\3c&H%x+&") then c32=text2:match("(\\3c&H%x+&)") 
		    if text:match("\\3c&H%x+&") then c31=text:match("(\\3c&H%x+&)") else c31="" end
		    if c31~=c32 then tf=tf..c32 end
		end
		if text2:match("\\4c&H%x+&") then c42=text2:match("(\\4c&H%x+&)") 
		    if text:match("\\4c&H%x+&") then c41=text:match("(\\4c&H%x+&)") else c41="" end
		    if c41~=c42 then tf=tf..c42 end
		end
		-- alphas
		if text2:match("\\alpha&H%x+&") then alpha2=text2:match("(\\alpha&H%x+&)") 
		    if text:match("\\alpha&H%x+&") then alpha1=text:match("(\\alpha&H%x+&)") else alpha1="" end
		    if alpha1~=alpha2 then tf=tf..alpha2 end
		end
		if text2:match("\\1a&H%x+&") then a12=text2:match("(\\1a&H%x+&)") 
		    if text:match("\\1a&H%x+&") then a11=text:match("(\\1a&H%x+&)") else a11="" end
		    if a11~=a12 then tf=tf..a12 end
		end
		if text2:match("\\2a&H%x+&") then a22=text2:match("(\\2a&H%x+&)") 
		    if text:match("\\2a&H%x+&") then a21=text:match("(\\2a&H%x+&)") else a21="" end
		    if a21~=a22 then tf=tf..a22 end
		end
		if text2:match("\\3a&H%x+&") then a32=text2:match("(\\3a&H%x+&)") 
		    if text:match("\\3a&H%x+&") then a31=text:match("(\\3a&H%x+&)") else a31="" end
		    if a31~=a32 then tf=tf..a32 end
		end
		if text2:match("\\4a&H%x+&") then a42=text2:match("(\\4a&H%x+&)") 
		    if text:match("\\4a&H%x+&") then a41=text:match("(\\4a&H%x+&)") else a41="" end
		    if a41~=a42 then tf=tf..a42 end
		end
		-- rotations
		if text2:match("\\frz[%d%.%-]+") then frz2=text2:match("(\\frz[%d%.%-]+)") zz2=tonumber(text2:match("\\frz([%d%.%-]+)"))
		    if text:match("\\frz[%d%.%-]+") then frz1=text:match("(\\frz[%d%.%-]+)") zz1=tonumber(text:match("\\frz([%d%.%-]+)"))
		    else frz1="" zz1="0" end
		    if frz1~=frz2 then 
			if res.rot and math.abs(zz2-zz1)>180 then
			    if zz2>zz1 then zz2=zz2-360 frz2="\\frz"..zz2 else 
			    zz1=zz1-360 text=text:gsub("\\frz[%d%.%-]+","\\frz"..zz1)
			    end
			end
		    tf=tf..frz2 end
		end
		if text2:match("\\frx[%d%.%-]+") then frx2=text2:match("(\\frx[%d%.%-]+)") xx2=tonumber(text2:match("\\frx([%d%.%-]+)"))
		    if text:match("\\frx[%d%.%-]+") then frx1=text:match("(\\frx[%d%.%-]+)") xx1=tonumber(text:match("\\frx([%d%.%-]+)"))
		    else frx1="" xx1="0" end
		    if frx1~=frx2 then 
			if res.rot and math.abs(xx2-xx1)>180 then
			    if xx2>xx1 then xx2=xx2-360 frx2="\\frx"..xx2 else 
			    xx1=xx1-360 text=text:gsub("\\frx[%d%.%-]+","\\frx"..xx1)
			    end
			end
		    tf=tf..frx2 end
		end
		if text2:match("\\fry[%d%.%-]+") then fry2=text2:match("(\\fry[%d%.%-]+)") yy2=tonumber(text2:match("\\fry([%d%.%-]+)"))
		    if text:match("\\fry[%d%.%-]+") then fry1=text:match("(\\fry[%d%.%-]+)") yy1=tonumber(text:match("\\fry([%d%.%-]+)"))
		    else fry1="" yy1="0"  end
		    if fry1~=fry2 then 
			if res.rot and math.abs(yy2-yy1)>180 then
			    if yy2>yy1 then yy2=yy2-360 fry2="\\fry"..yy2 else 
			    yy1=yy1-360 text=text:gsub("\\fry[%d%.%-]+","\\fry"..yy1)
			    end
			end
		    tf=tf..fry2 end
		end
		-- shearing
		if text2:match("\\fax[%d%.%-]+") then fax2=text2:match("(\\fax[%d%.%-]+)") 
		    if text:match("\\fax[%d%.%-]+") then fax1=text:match("(\\fax[%d%.%-]+)") else fax1="" end
		    if fax1~=fax2 then tf=tf..fax2 end
		end
		if text2:match("\\fay[%d%.%-]+") then fay2=text2:match("(\\fay[%d%.%-]+)") 
		    if text:match("\\fay[%d%.%-]+") then fay1=text:match("(\\fay[%d%.%-]+)") else fay1="" end
		    if fay1~=fay2 then tf=tf..fay2 end
		end
		-- apply transform
		if tf~="" then
		    text=text:gsub("^({\\[^}]-)}","%1\\t("..movt..","..tf..")}")
		end
		
		-- delete line 2
		if res.keep==false then subs.delete(sel[i]+1) end
		
	    end -- end of transmove
		
	    if res.move=="horizontal" then
		    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)","\\move(%1,%2,%3,%2") end
	    if res.move=="vertical" then
		    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)","\\move(%1,%2,%1,%4") end
	    
	    if res.move=="shiftmove" then
		xx=res.eks	yy=res.wai
		text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
		function(a,b,c,d) return "\\move("..a.. "," ..b.. "," ..c+xx.. "," ..d+yy end)
	    end
	    
	line.text=text
        subs[sel[i]] = line
    end
end

function multimove(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	-- error if first line's missing \move tag
	if x==1 and text:match("\\move")==nil then aegisub.dialog.display({{class="label",
		    label="Missing \\move tag on line 1",x=0,y=0,width=1,height=2}},{"OK"})
		    mc=1
	else 
	-- get coordinates from \move on line 1
	    if text:match("\\move") then
	    x1,y1,x2,y2,t,m1,m2=nil
		if text:match("\\move%([%d%.%-]+%,[%d%.%-]+%,[%d%.%-]+%,[%d%.%-]+%,[%d%.%,%-]+%)") then
		x1,y1,x2,y2,t=text:match("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%,%-]+)%)")
		else
		x1,y1,x2,y2=text:match("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%)")
		end
	    m1=x2-x1	m2=y2-y1	-- difference between start/end position
	    end
	-- error if any of lines 2+ don't have \pos tag
	    if x~=1 and text:match("\\pos")==nil then poscheck=1
	    else  
	-- apply move coordinates to lines 2+
		if x~=1 and m2~=nil then
		p1,p2=text:match("\\pos%(([%d%.]+)%,([%d%.]+)%)")
		    if t~=nil then
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\move%(%1,%2,"..p1+m1..","..p2+m2..","..t.."%)")
		    else
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\move(%1,%2,"..p1+m1..","..p2+m2..")")
		    end
		end
	    end
	    
	end
	    line.text = text
	    subs[i] = line
    end
	if poscheck==1 then aegisub.dialog.display({{class="label",
		label="Some lines are missing \\pos tags",x=0,y=0,width=1,height=2}},{"OK"}) end
	x1,y1,x2,y2,t,m1,m2=nil
	poscheck=0 
end

function shiftmove(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	xx=res.eks
	yy=res.wai
	if res.mod=="shiftmove" then
	    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a.. "," ..b.. "," ..c+xx.. "," ..d+yy end)
	end
	line.text=text
        subs[i] = line
    end
end

function modifier(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	
	    if res.mod=="round numbers" then
		if text:match("\\pos") and res.rnd=="all" or text:match("\\pos") and res.rnd=="pos" then
		px,py=text:match("\\pos%(([%d%.]+),([%d%.]+)%)")
		if px-math.floor(px)>=0.5 then px=math.ceil(px) else px=math.floor(px) end
		if py-math.floor(py)>=0.5 then py=math.ceil(py) else py=math.floor(py) end
		text=text:gsub("\\pos%([%d%.]+,[%d%.]+%)","\\pos("..px..","..py..")")
		end
		if text:match("\\org") and res.rnd=="all" or text:match("\\org") and res.rnd=="org" then
		ox,oy=text:match("\\org%(([%d%.]+),([%d%.]+)%)")
		if ox-math.floor(ox)>=0.5 then ox=math.ceil(ox) else ox=math.floor(ox) end
		if oy-math.floor(oy)>=0.5 then oy=math.ceil(oy) else oy=math.floor(oy) end
		text=text:gsub("\\org%([%d%.]+,[%d%.]+%)","\\org("..ox..","..oy..")")
		end
		if text:match("\\move") and res.rnd=="all" or text:match("\\move") and res.rnd=="move" then
		mo1,mo2,mo3,mo4=text:match("\\move%(([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")
		if mo1-math.floor(mo1)>=0.5 then mo1=math.ceil(mo1) else mo1=math.floor(mo1) end
		if mo2-math.floor(mo2)>=0.5 then mo2=math.ceil(mo2) else mo2=math.floor(mo2) end
		if mo3-math.floor(mo3)>=0.5 then mo3=math.ceil(mo3) else mo3=math.floor(mo3) end
		if mo4-math.floor(mo4)>=0.5 then mo4=math.ceil(mo4) else mo4=math.floor(mo4) end
		text=text:gsub("\\move%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+","\\move("..mo1..","..mo2..","..mo3..","..mo4)
		end
		if text:match("\\clip%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+") and res.rnd=="all" or text:match("\\clip%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+") and res.rnd=="clip" then
		mo1,mo2,mo3,mo4=text:match("\\i?clip%(([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")
		if mo1-math.floor(mo1)>=0.5 then mo1=math.ceil(mo1) else mo1=math.floor(mo1) end
		if mo2-math.floor(mo2)>=0.5 then mo2=math.ceil(mo2) else mo2=math.floor(mo2) end
		if mo3-math.floor(mo3)>=0.5 then mo3=math.ceil(mo3) else mo3=math.floor(mo3) end
		if mo4-math.floor(mo4)>=0.5 then mo4=math.ceil(mo4) else mo4=math.floor(mo4) end
		text=text:gsub("(\\i?clip)%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+","%1("..mo1..","..mo2..","..mo3..","..mo4)
		end
	    end
	    
	    if res.mod=="reverse move" then
		text=text:gsub("\\move%(([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)","\\move(%3,%4,%1,%2")
	    end
	       
	    if res.mod=="FReeZe" then
		frz=res.freeze
		if text:match("^{[^}]*\\frz") then
		text=text:gsub("^({[^}]*\\frz)([%d%.%-]+)","%1"..frz) 
		else
		text=text:gsub("^({\\[^}]*)}","%1\\frz"..frz.."}") 
		end
	    end
	    
	line.text=text
        subs[i] = line
    end
end

function clone(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	if not text:match("^{\\") then text=text:gsub("^","{\\}") end

	if res.pos then
		if x==1 and text:match("\\pos") then
		posi=text:match("\\pos%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\pos") and posi~=nil	 then
		text=text:gsub("\\pos%([^%)]-%)","\\pos%("..posi.."%)")
		end
		if x~=1 and not text:match("\\pos") and not text:match("\\move") and posi~=nil and res.cre then
		text=text:gsub("^{\\","{\\pos%("..posi.."%)\\")
		end
	
		if x==1 and text:match("\\move") then
		move=text:match("\\move%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\move") and move~=nil then
		text=text:gsub("\\move%([^%)]-%)","\\move%("..move.."%)")
		end
		if x~=1 and not text:match("\\move") and not text:match("\\pos") and move~=nil and res.cre then
		text=text:gsub("^{\\","{\\move%("..move.."%)\\")
		end
	end
	
	if res.org then
		if x==1 and text:match("\\org") then
		orig=text:match("\\org%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\org") and orig~=nil then
		text=text:gsub("\\org%([^%)]-%)","\\org%("..orig.."%)")
		end
		if x~=1 and not text:match("\\org") and orig~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\org%("..orig.."%)}")
		end
	end
	
	if res.clip then
		if x==1 and text:match("\\i?clip") then
		klip=text:match("\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and klip~=nil then
		text=text:gsub("\\(i?clip)%([^%)]-%)","\\%1%("..klip.."%)")
		end
		if x~=1 and not text:match("\\i?clip") and klip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\clip%("..klip.."%)}")
		end
	end
	
	if res.tclip then
		if x==1 and text:match("\\t%([%d%.%,]*\\i?clip") then
		tklip=text:match("\\t%([%d%.%,]*\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and tklip~=nil then
		text=text:gsub("\\t%(([%d%.%,]*)\\(i?clip)%([^%)]-%)","\\t%(%1\\%2%("..tklip.."%)")
		end
		if x~=1 and not text:match("\\t%([%d%.%,]*\\i?clip") and tklip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\t%(\\clip%("..tklip.."%)%)}")
		end
	end

	text=text
	:gsub("\\\\","\\")
	:gsub("\\}","}")
	:gsub("{}","")
	
	line.text = text
	subs[i] = line
    end
    posi, move, orig, klip, tklip=nil
end

function teleport(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	xx=res.eks
	yy=res.wai

	if res.tppos then
	    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\pos(".. a+xx.. "," ..b+yy..")" end)
	end

	if res.tporg then
	    text=text:gsub("\\org%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\org(".. a+xx.. "," ..b+yy..")" end)
	end

	if res.tpmov then
	    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	end

	if res.tpclip then
	    text=text:gsub("clip%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "clip("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	    
	    if text:match("clip%(m [%d%a%s%-]+%)") then
	    ctext=text:match("clip%(m ([%d%a%s%-]+)%)")
	    ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a+xx.." "..b+yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub(ctext,ctext2)
	    end
	end

	line.text = text
	subs[i] = line
    end
end

function relocator(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=2,height=1,class="label",label="Repositioning Field",},
	    {x=0,y=1,width=1,height=1,class="dropdown",name="posi",items={"Align X","Align Y"},value="Align X",},
	    {x=0,y=2,width=1,height=1,class="floatedit",name="post",value=0},
	    {x=0,y=3,width=1,height=1,class="checkbox",name="first",label="align with first",value=align_with_first,},
	    
	    {x=2,y=0,width=2,height=1,class="label",label="Soul Bilocator"},
	    {x=2,y=1,width=1,height=1,class="dropdown",name="move",
		items={"transmove","horizontal","vertical","multimove","shiftmove"},value="transmove",},
	    {x=2,y=2,width=1,height=1,class="checkbox",name="keep",label="keep both",value=keep_both,},
	    {x=2,y=3,width=3,height=1,class="checkbox",name="rot",label="rotation acceleration",value=rotation_acceleration,},
	    
	    {x=4,y=0,width=2,height=1,class="label",label="Morphing Grounds",},
	    {x=4,y=1,width=2,height=1,class="dropdown",name="mod",
		items={"round numbers","reverse move","FReeZe"},value="round numbers"},
	    {x=4,y=2,width=1,height=1,class="label",label="Round:",},
	    {x=5,y=2,width=1,height=1,class="dropdown",name="rnd",items={"all","pos","move","org","clip"},value="all"},
	    {x=5,y=3,width=1,height=1,class="dropdown",name="freeze",
		items={"-frz-","30","45","60","90","120","135","150","180","-30","-45","-60","-90","-120","-135","-150"},value="-frz-"},
	    
	    {x=6,y=0,width=3,height=1,class="label",label="Cloning Laboratory",},
	    {x=6,y=1,width=2,height=1,class="checkbox",name="pos",label="\\posimove",value=cc_posimove },
	    {x=8,y=1,width=1,height=1,class="checkbox",name="org",label="\\org",value=cc_org },
	    {x=6,y=2,width=1,height=1,class="checkbox",name="clip",label="\\[i]clip",value=cc_clip },
	    {x=7,y=2,width=2,height=1,class="checkbox",name="tclip",label="\\t(\\[i]clip)",value=cc_tclip },
	    {x=6,y=3,width=4,height=1,class="checkbox",name="cre",label="replicate missing tags",value=cc_replicate_tags },
	    
	    {x=10,y=0,width=2,height=1,class="label",label="Teleportation",},
	    {x=10,y=1,width=3,height=1,class="floatedit",name="eks",hint="X"},
	    {x=10,y=2,width=3,height=1,class="floatedit",name="wai",hint="Y"},

	    {x=12,y=0,width=1,height=1,class="checkbox",name="tppos",label="pos",value=tele_pos },
	    {x=10,y=3,width=1,height=1,class="checkbox",name="tpmov",label="move",value=tele_move },
	    {x=11,y=3,width=1,height=1,class="checkbox",name="tpclip",label="clip",value=tele_clip },
	    {x=12,y=3,width=1,height=1,class="checkbox",name="tporg",label="org",value=tele_org },
 	} 
	
	pressed, res = aegisub.dialog.display(dialog_config,
	{"Positron Cannon","Hyperspace Travel","Metamorphosis","Cloning Sequence","Teleportation","Disintegrate"},{cancel='Disintegrate'})
	if pressed=="Disintegrate" then aegisub.cancel() end
	
	if pressed=="Positron Cannon" then positron(subs, sel) end
	if pressed=="Hyperspace Travel" then
	    if res.move=="multimove" then multimove (subs, sel) else bilocator(subs, sel) end
	end
	if pressed=="Metamorphosis" then modifier(subs, sel) end
	if pressed=="Cloning Sequence" then clone(subs, sel) end
	if pressed=="Teleportation" then teleport(subs, sel) end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, relocator)