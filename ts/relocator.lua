-- Hyperdimensional Relocator offers a plethora of functions, focusing primarily on \pos, \move, \org, \clip, and rotations.
-- Check Help (Space Travel Guide) for detailed description of all functions.

script_name="Hyperdimensional Relocator"
script_description="Makes things appear different from before"
script_author="reanimated"
script_version="2.0"

--	SETTINGS	--

align_with_first=false
keep_both=false
rotation_acceleration=true

cc_posimove=true
cc_org=true
cc_clip=true
cc_tclip=true
cc_replicate_tags=true
cc_stack_clips=false
cc_match_clip_type=false
cc_combine_vectors=false
cc_copy_rotations=false

tele_pos=true
tele_move=true
tele_clip=true
tele_org=true

delete_orig_line_in_line2fbf=false

--  --	--  --	--  --	--

include("utils.lua")

function positron(subs,sel)
    ps=res.post
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Depositing line %d/%d",x,#sel))
	local line=subs[i]
	local text=line.text
	if x==1 and not text:match("\\pos") and res.posi~="clip to fax" then aegisub.dialog.display({{class="label",
	    label="No \\pos tag in the first line.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'}) aegisub.cancel()  end
		    
	if x==1 and res.first then pxx,pyy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
		if res.posi=="Align X" then ps=pxx else ps=pyy end
	end
	
	-- Align X
	if res.posi=="Align X" then
	    text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","\\pos("..ps..",%2)")
	
	-- Align Y
	elseif res.posi=="Align Y" then
	    text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","\\pos(%1,"..ps..")")
	
	-- Mirrors
	elseif res.posi:match"mirror" then
	    if not text:match("\\pos") then 
		aegisub.dialog.display({{class="label",label="Fail. Some lines are missing \\pos.",width=1,height=2}},{"OK"},{close='OK'})
		aegisub.cancel() 
	    end
	    info(subs)
	    if res.post~=0 and res.post~=nil then resx=2*res.post resy=2*res.post end
	    if res.posi=="horizontal mirror" then
	    text2=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)",function(x,y) return "\\pos("..resx-x..","..y..")" end)
	    	if res.mirr then 
		    if not text2:match("^{[^}]-\\fry") then text2=addtag("\\fry0",text2) end text2=flip("fry",text2)
		end
	    else
	    text2=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)",function(x,y) return "\\pos("..x..","..resy-y..")" end)
	    	if res.mirr then 
		    if not text2:match("^{[^}]-\\frx") then text2=addtag("\\frx0",text2) end text2=flip("frx",text2)
		end
	    end
	    l2=line	l2.text=text2
	    subs.insert(i+1,l2)
	    for i=x,#sel do sel[i]=sel[i]+1 end
	
	-- org to fax
	elseif res.posi=="org to fax" then
	    if not text:match("\\org") then
		aegisub.dialog.display({{class="label",label="Missing \\org.",width=1,height=2}},{"OK"},{close='OK'})
		aegisub.cancel()
	    end
	    pox,poy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)")
	    orx,ory=text:match("\\org%(([%d%.%-]+),([%d%.%-]+)")
	    rota=text:match("\\frz([%d%.%-]+)")
	    if rota==nil then rota=0 end
	    ad=pox-orx
	    op=poy-ory
	    tang=(ad/op)
	    ang1=math.deg(math.atan(tang))
	    ang2=ang1-rota
	    tangf=math.tan(math.rad(ang2))
	    
	    faks=round1(tangf*100)/100
	    text=addtag("\\fax"..faks,text)
	    text=text:gsub("\\org%([^%)]+%)","")
	    text=duplikill(text)
	
	-- clip to fax
	elseif res.posi=="clip to fax" then
	    if not text:match("\\clip") then
		aegisub.dialog.display({{class="label",label="Missing \\clip.",width=1,height=2}},{"OK"},{close='OK'})
		aegisub.cancel()
	    end
	    cx1,cy1,cx2,cy2=text:match("\\clip%(m ([%d%-]+) ([%d%-]+) l ([%d%-]+) ([%d%-]+)")
	    rota=text:match("\\frz([%d%.%-]+)")
	    if rota==nil then rota=0 end
	    ad=cx1-cx2
	    op=cy1-cy2
	    tang=(ad/op)
	    ang1=math.deg(math.atan(tang))
	    ang2=ang1-rota
	    tangf=math.tan(math.rad(ang2))
	    
	    faks=round1(tangf*100)/100
	    text=addtag("\\fax"..faks,text)
	    text=text:gsub("\\clip%([^%)]+%)","")
	    text=duplikill(text)
	end

	line.text=text
        subs[i]=line
    end
    return sel
end

function bilocator(subs, sel)
    for i=#sel,1,-1 do
        aegisub.progress.title(string.format("Moving through hyperspace... %d/%d",(#sel-i+1),#sel))
	line=subs[sel[i]]
	text=line.text
	
	    if res.move=="transmove" and sel[i]<#subs then
	    
	    	start=line.start_time		-- start time
		endt=line.end_time		-- end time
		nextline=subs[sel[i]+1]
		text2=nextline.text
		text=text:gsub("\\1c","\\c")
		text2=text2:gsub("\\1c","\\c")
		
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
		
		tftags={"fs","fsp","fscx","fscy","blur","bord","shad","fax","fay"}
		for tg=1,#tftags do
		  t=tftags[tg]
		  if text2:match("\\"..t.."[%d%.%-]+") then tag2=text2:match("(\\"..t.."[%d%.%-]+)") 
		    if text:match("\\"..t.."[%d%.%-]+") then tag1=text:match("(\\"..t.."[%d%.%-]+)") else tag1="" end
		    if tag1~=tag2 then tf=tf..tag2 end
		  end
		end
		
		tfctags={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
		for tg=1,#tfctags do
		  t=tfctags[tg]
		  if text2:match("\\"..t.."&H%x+&") then tag2=text2:match("(\\"..t.."&H%x+&)") 
		    if text:match("\\"..t.."&H%x+&") then tag1=text:match("(\\"..t.."&H%x+&)") else tag1="" end
		    if tag1~=tag2 then tf=tf..tag2 end
		  end
		end
		
		tfrtags={"frz","frx","fry"}
		for tg=1,#tfrtags do
		  t=tfrtags[tg]
		  if text2:match("\\"..t.."[%d%.%-]+") then 
		    tag2=text2:match("(\\"..t.."[%d%.%-]+)") rr2=tonumber(text2:match("\\"..t.."([%d%.%-]+)"))
		    if text:match("\\"..t.."[%d%.%-]+") then 
		        tag1=text:match("(\\"..t.."[%d%.%-]+)") rr1=tonumber(text:match("\\"..t.."([%d%.%-]+)"))
		    else tag1="" rr1="0" end
		    if tag1~=tag2 then 
			if res.rot and math.abs(rr2-rr1)>180 then
			    if rr2>rr1 then rr2=rr2-360 tag2="\\frz"..rr2 else 
			    rr1=rr1-360 text=text:gsub("\\frz[%d%.%-]+","\\frz"..rr1)
			    end
			end
		    tf=tf..tag2 end
		  end
		end
		
		-- apply transform
		if tf~="" then
		    text=text:gsub("^({\\[^}]-)}","%1\\t("..movt..","..tf..")}")
		end
		
		-- delete line 2
		if res.keep==false then subs.delete(sel[i]+1) end
		
	    end -- end of transmove
		
	    if res.move=="horizontal" then
		    text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%1,%2,%3,%2") end
	    if res.move=="vertical" then
		    text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%1,%2,%1,%4") end
	    
	    if res.move=="rvrs. move" then
		text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%3,%4,%1,%2")
	    end
	    
	    if res.move=="shiftmove" then
		xx=res.eks	yy=res.wai
		text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
		function(a,b,c,d) return "\\move("..a..","..b..","..c+xx..","..d+yy end)
		text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)",function(a,b) return "\\move("..a..","..b..","..a+xx..","..b+yy end)
	    end
	    
	    if res.move=="shiftstart" then
		xx=res.eks	yy=res.wai
		text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
		function(a,b,c,d) return "\\move("..a+xx..","..b+yy..","..c..","..d end)
	    end
	    
	    if res.move=="move clip" then
		m1,m2,m3,m4=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
		mt=text:match("\\move%([^,]+,[^,]+,[^,]+,[^,]+,([%d%.,%-]+)")
		if mt==nil then mt="" else mt=mt.."," end
		klip=text:match("\\i?clip%([%d%.,%-]+%)")
		klip=klip:gsub("(\\i?clip%()([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
		function(a,b,c,d,e) return a..b+m3-m1..","..c+m4-m2..","..d+m3-m1..","..e+m4-m2 end)
		text=addtag("\\t("..mt..klip..")",text)
	    end
	    
	line.text=text
        subs[sel[i]]=line
    end
end

function multimove(subs, sel)
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Synchronizing movement... %d/%d",x,#sel))
	local line=subs[i]
        local text=subs[i].text
	-- error if first line's missing \move tag
	if x==1 and text:match("\\move")==nil then aegisub.dialog.display({{class="label",
		    label="Missing \\move tag on line 1",x=0,y=0,width=1,height=2}},{"OK"})
		    mc=1
	else 
	-- get coordinates from \move on line 1
	    if text:match("\\move") then
	    x1,y1,x2,y2,t,m1,m2=nil
		if text:match("\\move%([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.,%-]+%)") then
		x1,y1,x2,y2,t=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.,%-]+)%)")
		else
		x1,y1,x2,y2=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)")
		end
	    m1=x2-x1	m2=y2-y1	-- difference between start/end position
	    end
	-- error if any of lines 2+ don't have \pos tag
	    if x~=1 and text:match("\\pos")==nil then poscheck=1
	    else  
	-- apply move coordinates to lines 2+
		if x~=1 and m2~=nil then
		p1,p2=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
		    if t~=nil then
		    text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","\\move%(%1,%2,"..p1+m1..","..p2+m2..","..t.."%)")
		    else
		    text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","\\move(%1,%2,"..p1+m1..","..p2+m2..")")
		    end
		end
	    end
	    
	end
	    line.text=text
	    subs[i]=line
    end
	if poscheck==1 then aegisub.dialog.display({{class="label",
		label="Some lines are missing \\pos tags",x=0,y=0,width=1,height=2}},{"OK"}) end
	x1,y1,x2,y2,t,m1,m2=nil
	poscheck=0 
end

function round(a,b,c,d)
	a=math.floor(a+0.5)
	b=math.floor(b+0.5)
	c=math.floor(c+0.5)
	d=math.floor(d+0.5)
	return a,b,c,d
end

function round1(a)
	a=math.floor(a+0.5)
	return a
end

function modifier(subs, sel)
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Morphing... %d/%d",x,#sel))
	local line=subs[i]
	local text=line.text
	    
	    if res.mod=="fullmovetimes" or res.mod=="fulltranstimes" then
		start=line.start_time		-- start time
		endt=line.end_time		-- end time
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		start2=fr2ms(startf)
		endt2=fr2ms(endf-1)
		tim=fr2ms(1)
		movt1=start2-start+tim		-- first timecode in \move
		movt2=endt2-start+tim		-- second timecode in \move
		movt=movt1..","..movt2
	    end
		
	    if res.mod=="round numbers" then
		if text:match("\\pos") and res.rnd=="all" or text:match("\\pos") and res.rnd=="pos" then
		px,py=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
		px,py=round(px,py,0,0)
		text=text:gsub("\\pos%([%d%.%-]+,[%d%.%-]+%)","\\pos("..px..","..py..")")
		end
		if text:match("\\org") and res.rnd=="all" or text:match("\\org") and res.rnd=="org" then
		ox,oy=text:match("\\org%(([%d%.%-]+),([%d%.%-]+)%)")
		ox,oy=round(ox,oy,0,0)
		text=text:gsub("\\org%([%d%.%-]+,[%d%.%-]+%)","\\org("..ox..","..oy..")")
		end
		if text:match("\\move") and res.rnd=="all" or text:match("\\move") and res.rnd=="move" then
		mo1,mo2,mo3,mo4=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
		mo1,mo2,mo3,mo4=round(mo1,mo2,mo3,mo4)
		text=text:gsub("\\move%([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+","\\move("..mo1..","..mo2..","..mo3..","..mo4)
		end
		if text:match("\\i?clip") and res.rnd=="all" or text:match("\\i?clip") and res.rnd=="clip" then
		for klip in text:gmatch("\\i?clip%([^%)]+%)") do
		klip2=klip:gsub("([%d%.%-]+)",function(c) return round1(c) end)
		klip=esc(klip)
		text=text:gsub(klip,klip2)
		end
		end
	    end
	    
	    if res.mod=="killmovetimes" then
		text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%1,%2,%3,%4")
	    end
	    
	    if res.mod=="fullmovetimes" then
		text=text:gsub("\\move%(([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%1,"..movt)
		text=text:gsub("\\move%(([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+)%)","\\move(%1,"..movt..")")
	    end
	    
	    if res.mod=="fulltranstimes" then
		text=text:gsub("\\t%([%d,%.]-\\","\\t("..movt..",\\")
		text=text:gsub("\\t%(\\","\\t("..movt..",\\")
	    end
	    
	    if res.mod=="move v. clip" then
		if x==1 then v1,v2=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") 
			if v1==nil then 
			aegisub.dialog.display({{class="label",label="Error. No \\pos tag on line 1.",x=0,y=0,width=1,height=2}},
			{"OK"},{close='OK'}) aegisub.cancel() end
		end
		if x~=1 and text:match("\\pos") then v3,v4=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") 
		  V1=v3-v1	V2=v4-v2
		  if text:match("clip%(m [%d%a%s%-%.]+%)") then
		    ctext=text:match("clip%(m ([%d%a%s%-%.]+)%)")
		    ctext2=ctext:gsub("([%d%-%.]+)%s([%d%-%.]+)",function(a,b) return a+V1.." "..b+V2 end)
		    ctext=ctext:gsub("%-","%%-")
		    text=text:gsub("clip%(m "..ctext,"clip(m "..ctext2)
		  end
		  if text:match("clip%(%d+,m [%d%a%s%-%.]+%)") then
		    fac,ctext=text:match("clip%((%d+),m ([%d%a%s%-%.]+)%)")
		    factor=2^(fac-1)
		    ctext2=ctext:gsub("([%d%-%.]+)%s([%d%-%.]+)",function(a,b) return a+factor*V1.." "..b+factor*V2 end)
		    ctext=ctext:gsub("%-","%%-")
		    text=text:gsub(",m "..ctext,",m "..ctext2)
		  end
		end
	    end
	    
	    if res.mod=="set origin" then
		text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)",
		function(a,b) return "\\pos("..a..","..b..")\\org("..a+res.eks..","..b+res.wai..")" end)
	    end
	    
	    if res.mod=="calculate origin" then
		local c={}
		local c2={}
		x1,y1,x2,y2,x3,y3,x4,y4=text:match("clip%(m ([%d%-]+) ([%d%-]+) l ([%d%-]+) ([%d%-]+) ([%d%-]+) ([%d%-]+) ([%d%-]+) ([%d%-]+)")
		cor1={x=tonumber(x1),y=tonumber(y1)} table.insert(c,cor1) table.insert(c2,cor1)
		cor2={x=tonumber(x2),y=tonumber(y2)} table.insert(c,cor2) table.insert(c2,cor2)
		cor3={x=tonumber(x3),y=tonumber(y3)} table.insert(c,cor3) table.insert(c2,cor3)
		cor4={x=tonumber(x4),y=tonumber(y4)} table.insert(c,cor4) table.insert(c2,cor4)
		table.sort(c, function(a,b) return tonumber(a.x)<tonumber(b.x) end)	-- sorted by x
		table.sort(c2, function(a,b) return tonumber(a.y)<tonumber(b.y) end)	-- sorted by y
		-- i don't even know myself how all this shit works
		xx1=c[1].x	yy1=c[1].y
		xx2=c[4].x	yy2=c[4].y
		yy3=c2[1].y	xx3=c2[1].x
		yy4=c2[4].y	xx4=c2[4].x
		distx1=c[2].x-c[1].x	disty1=c[2].y-c[1].y
		distx2=c[4].x-c[3].x	disty2=c[4].y-c[3].y
		distx3=c2[2].x-c2[1].x		disty3=c2[2].y-c2[1].y
		distx4=c2[4].x-c2[3].x		disty4=c2[4].y-c2[3].y
		
		-- x/y factor / angle / whatever
		fx1=math.abs(disty1/distx1)
		fx2=math.abs(disty2/distx2)
		fx3=math.abs(distx3/disty3)
		fx4=math.abs(distx4/disty4)
		
		-- determine if y is going up or down
		cy=1
		  if c[2].y>c[1].y then cx1=round1(xx1-(yy1-cy)/fx1) else cx1=round1(xx1+(yy1-cy)/fx1) end
		  if c[4].y>c[3].y then cx2=round1(xx2-(yy2-cy)/fx2) else cx2=round1(xx2+(yy2-cy)/fx2) end	
		  top=cx2-cx1
		cy=500
		  if c[2].y>c[1].y then cx1=round1(xx1-(yy1-cy)/fx1) else cx1=round1(xx1+(yy1-cy)/fx1) end
		  if c[4].y>c[3].y then cx2=round1(xx2-(yy2-cy)/fx2) else cx2=round1(xx2+(yy2-cy)/fx2) end	
		  bot=cx2-cx1
		if top>bot then cy=c2[4].y ycalc=1 else cy=c2[1].y ycalc=-1 end
		
		-- LOOK FOR ORG X
		repeat
		  if c[2].y>c[1].y then cx1=round1(xx1-(yy1-cy)/fx1) else cx1=round1(xx1+(yy1-cy)/fx1) end
		  if c[4].y>c[3].y then cx2=round1(xx2-(yy2-cy)/fx2) else cx2=round1(xx2+(yy2-cy)/fx2) end
		  cy=cy+ycalc
		  -- aegisub.log("\n cx1: "..cx1.."   cx2: "..cx2.."   cy: "..cy)
		until cx1>=cx2 or math.abs(cy)==50000
		org1=cx1
		
		-- determine if x is going left or right
		cx=1
		  if c2[2].x>c2[1].x then cy1=round1(yy3-(xx3-cx)/fx3) else cy1=round1(yy3+(xx3-cx)/fx3) end
		  if c2[4].x>c2[3].x then cy2=round1(yy4-(xx4-cx)/fx4) else cy2=round1(yy4+(xx4-cx)/fx4) end
		  left=cy2-cy1
		cx=500
		  if c2[2].x>c2[1].x then cy1=round1(yy3-(xx3-cx)/fx3) else cy1=round1(yy3+(xx3-cx)/fx3) end
		  if c2[4].x>c2[3].x then cy2=round1(yy4-(xx4-cx)/fx4) else cy2=round1(yy4+(xx4-cx)/fx4) end
		  rite=cy2-cy1
		if left>rite then cx=c[4].x xcalc=1 else cx=c[1].x xcalc=-1 end
		
		-- LOOK FOR ORG Y
		repeat
		  if c2[2].x>c2[1].x then cy1=round1(yy3-(xx3-cx)/fx3) else cy1=round1(yy3+(xx3-cx)/fx3) end
		  if c2[4].x>c2[3].x then cy2=round1(yy4-(xx4-cx)/fx4) else cy2=round1(yy4+(xx4-cx)/fx4) end
		  cx=cx+xcalc
		  -- aegisub.log("\n cy1: "..cy1.."   cy2: "..cy2)
		until cy1>=cy2 or math.abs(cx)==50000
		org2=cy1
		
		text=text:gsub("\\org%([^%)]+%)","") 
		text=addtag("\\org("..org1..","..org2..")",text)
	    end
	       
	    if res.mod=="FReeZe" then
		frz=res.freeze
		if text:match("^{[^}]*\\frz") then
		text=text:gsub("^({[^}]*\\frz)([%d%.%-]+)","%1"..frz) 
		else
		text=addtag("\\frz"..frz,text)
		end
	    end
	    
	    if res.mod=="rotate 180" then
		if text:match("\\frz") then rot="frz" text=flip(rot,text)
		else
		text=addtag("\\frz180",text)
		end
	    end
	    
	    if res.mod=="flip hor." then
		if text:match("\\fry") then rot="fry" text=flip(rot,text)
		else
		text=addtag("\\fry180",text)
		end
	    end
	    
	    if res.mod=="flip vert." then
		if text:match("\\frx") then rot="frx" text=flip(rot,text)
		else
		text=addtag("\\frx180",text)
		end
	    end

	    if res.mod=="vector2rect." then
		text=text:gsub("\\clip%(m%s(%d-)%s(%d-)%sl%s(%d-)%s(%d-)%s(%d-)%s(%d-)%s(%d-)%s(%d-)%)","\\clip(%1,%2,%5,%6)") 
	    end

	    if res.mod=="rect.2vector" then
		text=text:gsub("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)",function(a,b,c,d) 
		a,b,c,d=round(a,b,c,d) return string.format("\\clip(m %d %d l %d %d %d %d %d %d)",a,b,c,b,c,d,a,d) end)
	    end

	    if res.mod=="letterbreak" then
	      if not text:match("^({\\[^}]-})") then
		notag1=text:match("^([^{]+)")
		local notag2=notag1:gsub("([%a%s%d])","%1\\N")
		notag=esc(notag1)
		text=text:gsub(notag1,notag2)
	      end
	      for notag in text:gmatch("{\\[^}]-}([^{]+)") do
		local notag2=notag:gsub("([%a%s%d])","%1\\N")
		notag=esc(notag)
		text=text:gsub(notag,notag2)
	      end
	      text=text:gsub("\\N$","")
	    end
	    
	    if res.mod=="wordbreak" then
	      if not text:match("^({\\[^}]-})") then
		notag1=text:match("^([^{]+)")
		local notag2=notag1:gsub("%s+"," \\N")
		notag=esc(notag1)
		text=text:gsub(notag1,notag2)
	      end
	      for notag in text:gmatch("{\\[^}]-}([^{]+)") do
		local notag2=notag:gsub("%s+"," \\N")
		notag=esc(notag)
		text=text:gsub(notag,notag2)
	      end
	      text=text:gsub("\\N$","")
	    end
	    
	line.text=text
        subs[i]=line
    end
end

function flip(rot,text)
    for rotation in text:gmatch("\\"..rot.."([%d%.%-]+)") do
	rotation=tonumber(rotation)
	if rotation<180 then newrot=rotation+180 end
	if rotation>180 then newrot=rotation-180 end
	text=text:gsub(rot..rotation,rot..newrot)
    end
    return text
end

function movetofbf(subs, sel)
    for i=#sel,1,-1 do
        line=subs[sel[i]]
        text=subs[sel[i]].text
	styleref=stylechk(subs,line.style)
		
	    start=line.start_time
	    endt=line.end_time
	    startf=ms2fr(start)
	    endf=ms2fr(endt)
	    frames=endf-1-startf
	    frnum=frames
	    l2=line
	    
		for frm=endf-1,startf,-1 do
		l2.text=text
			-- move
			if text:match("\\move") then
			    m1,m2,m3,m4=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
			    	mvstart,mvend=text:match("\\move%([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+,([%d%.%-]+),([%d%.%-]+)")
				if mvstart==nil then mvstart=fr2ms(startf)-start end
				if mvend==nil then mvend=fr2ms(endf-1)-start end
				mstartf=ms2fr(start+mvstart)		mendf=ms2fr(start+mvend)
				moffset=mstartf-startf		if moffset<0 then moffset=0 end
				mlimit=mendf-startf
				mpart=frnum-moffset
				mwhole=mlimit-moffset
			    pos1=math.floor((((m3-m1)/mwhole)*mpart+m1)*100)/100
			    pos2=math.floor((((m4-m2)/mwhole)*mpart+m2)*100)/100
				if mpart<0 then pos1=m1 pos2=m2 end
				if mpart>mlimit-moffset then pos1=m3 pos2=m4 end
			    l2.text=text:gsub("\\move%([^%)]*%)","\\pos("..pos1..","..pos2..")")
			end
			--fade
			if text:match("\\fad%(") then
			    f1,f2=text:match("\\fad%(([%d%.]+),([%d%.]+)")
			    	fad_in=ms2fr(start+f1)
				fad_out=ms2fr(endt-f2)
				foffset=fad_out-startf-1
				fendf=fad_in-startf
				fpart=frnum-foffset
				fwhole=endf-fad_out
				faf="&HFF&"	fa0="&H00&"
				fa1=interpolate_alpha(1/(fendf+3), faf, fa0)
				fa2=interpolate_alpha(1/(fwhole+3), faf, fa0)
			    val_in=interpolate_alpha(frnum/fendf, fa1, fa0)
			    val_out=interpolate_alpha(fpart/fwhole, fa0, fa2)
				if frnum<fad_in-startf then alfa=val_in
				elseif frnum>fad_out-startf then alfa=val_out
				else alfa=fa0 end
			    l2.text=text:gsub("\\fad%([^%)]*%)","\\alpha"..alfa)
			end
		  
		    tags=l2.text:match("^{[^}]*}")
		    if tags==nil then tags="" end
		    -- transforms
		    if tags:match("\\t") then
			text=text:gsub("^({\\[^}]-})",function(tg) return cleantr(tg) end)
			terraform(tags)
			
			l2.text=l2.text:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")	:gsub("(\\t%([^%(%)]-%))","")
			l2.text=l2.text:gsub("^({[^}]*)}","%1"..ftags.."}")
			
			l2.text=duplikill(l2.text)
		    end
		    
		    l2.start_time=fr2ms(frm)
		    l2.end_time=fr2ms(frm+1)
		    subs.insert(sel[i]+1,l2) table.insert(sel,sel[i]+frnum+1)
		    frnum=frnum-1
		end
		line.end_time=endt
		line.comment=true
	line.text=text
	subs[sel[i]]=line
	table.sort(sel)
	if res.delfbf then subs.delete(sel[i]) table.remove(sel,#sel) end
    end
    return sel
end

function terraform(tags)
	tra=tags:match("(\\t%([^%(%)]-%))")
	if tra==nil then tra=text:match("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") end	--aegisub.log("\ntra: "..tra)
	trstart,trend=tra:match("\\t%((%d+),(%d+)")
	if trstart==nil then trstart=fr2ms(startf)-start end
	if trend==nil then trend=fr2ms(endf-1)-start end
	tfstartf=ms2fr(start+trstart)		tfendf=ms2fr(start+trend)
	toffset=tfstartf-startf		if toffset<0 then toffset=0 end
	tlimit=tfendf-startf
	tpart=frnum-toffset
	twhole=tlimit-toffset
	nontra=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")	:gsub("(\\t%([^%(%)]-%))","")
	ftags=""
	-- most tags
	for tg, valt in tra:gmatch("\\(%a+)([%d%.%-]+)") do
		val1=nil
		if nontra:match(tg) then val1=nontra:match("\\"..tg.."([%d%.%-]+)") end
		if val1==nil then
		if tg=="bord" or tg=="xbord" or tg=="ybord" then val1=styleref.outline end
		if tg=="shad" or tg=="xshad" or tg=="yshad" then val1=styleref.shadow end
		if tg=="fs" then val1=styleref.fontsize end
		if tg=="fsp" then val1=styleref.spacing end
		if tg=="frz" then val1=styleref.angle end
		if tg=="fscx" then val1=styleref.scale_x end
		if tg=="fscy" then val1=styleref.scale_y end
		if tg=="blur" or tg=="be" or tg=="fax" or tg=="fay" or tg=="frx" or tg=="fry" then val1=0 end
		end
		valf=math.floor((((valt-val1)/twhole)*tpart+val1)*100)/100
		if tpart<0 then valf=val1 end
		if tpart>tlimit-toffset then valf=valt end
		ftags=ftags.."\\"..tg..valf
	end
	-- clip
	if tra:match("\\clip") then
	c1,c2,c3,c4=nontra:match("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
	k1,k2,k3,k4=tra:match("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
	tc1=math.floor((((k1-c1)/twhole)*tpart+c1)*100)/100
	tc2=math.floor((((k2-c2)/twhole)*tpart+c2)*100)/100
	tc3=math.floor((((k3-c3)/twhole)*tpart+c3)*100)/100
	tc4=math.floor((((k4-c4)/twhole)*tpart+c4)*100)/100
	if tpart<0 then tc1=c1 tc2=c2 tc3=c3 tc4=c4 end
	if tpart>tlimit-toffset then tc1=k1 tc2=k2 tc3=k3 tc4=k4 end
	ftags=ftags.."\\clip("..tc1..","..tc2..","..tc3..","..tc4..")"
	end
	-- colour/alpha
	tra=tra:gsub("\\1c","\\c")
	nontra=nontra:gsub("\\1c","\\c")
	for tg, valt in tra:gmatch("\\(%w+)(&H%x+&)") do
		val1=nil
		if nontra:match(tg) then val1=nontra:match("\\"..tg.."(&H%x+&)") end
		if val1==nil then
		if tg=="c" then val1=styleref.color1:gsub("H%x%x","H") end
		if tg=="2c" then val1=styleref.color2:gsub("H%x%x","H") end
		if tg=="3c" then val1=styleref.color3:gsub("H%x%x","H") end
		if tg=="4c" then val1=styleref.color4:gsub("H%x%x","H") end
		if tg=="1a" then val1=styleref.color1:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="2a" then val1=styleref.color2:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="3a" then val1=styleref.color3:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="4a" then val1=styleref.color4:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="alpha" then val1="&H00&" end
		end
		if tg:match("c") then valf=interpolate_color(tpart/twhole, val1, valt) end
		if tg:match("a") then valf=interpolate_alpha(tpart/twhole, val1, valt) end
		if tpart<0 then valf=val1 end
		if tpart>tlimit-toffset then valf=valt end
		ftags=ftags.."\\"..tg..valf
	end
end

function cleantr(tags)
	trnsfrm=""
	for t in tags:gmatch("(\\t%([^%(%)]-%))") do trnsfrm=trnsfrm..t end
	for t in tags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("(\\t%([^%(%)]+%))","")
	tags=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")
	tags=tags:gsub("^({\\[^}]*)}","%1"..trnsfrm.."}")

	cleant=""
	for ct in tags:gmatch("\\t%((\\[^%(%)]-)%)") do cleant=cleant..ct end
	for ct in tags:gmatch("\\t%((\\[^%(%)]-%([^%)]-%)[^%)]-)%)") do cleant=cleant..ct end
	tags=tags:gsub("(\\t%(\\[^%(%)]+%))","")
	tags=tags:gsub("(\\t%(\\[^%(%)]-%([^%)]-%)[^%)]-%))","")
	if cleant~="" then tags=tags:gsub("^({\\[^}]*)}","%1\\t("..cleant..")}") end
	return tags
end

function duplikill(text)
	tags1={"blur","be","bord","shad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%2%1")
	end
	text=text:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%2%1")
	end
	text=text:gsub("\\i?clip%([^%)]-%)([^}]-)(\\i?clip%([^%)]-%))","%2%1")
	return text
end

function joinfbflines(subs, sel)
    -- dialog
	joindialog={
	    {x=0,y=0,width=1,height=1,class="label",label="How many lines?",},
	    {x=0,y=1,width=1,height=1,class="intedit",name="join",value=2,step=1,min=2,max=50 },
	}
	pressed, res=aegisub.dialog.display(joindialog,{"OK"},{ok='OK'})
    -- number
    count=1
    for x, i in ipairs(sel) do
        local line=subs[i]
	line.effect=count
	if x==1 then line.effect="1" end
        subs[i]=line
	count=count+1
	if count>res.join then count=1 end
    end
    -- delete & time
    total=#sel
    for i=#sel,1,-1 do
	local line=subs[sel[i]]
	if line.effect==tostring(res.join) then endtime=line.end_time end
	if i==total then endtime=line.end_time end
	if line.effect=="1" then line.end_time=endtime line.effect="" subs[sel[i]]=line 
	else subs.delete(sel[i]) table.remove(sel,#sel) end
    end
    return sel
end

function negativerot(subs, sel)
	negdialog={
	{x=0,y=0,width=1,height=1,class="checkbox",name="frz",label="frz",value=true},
	{x=1,y=0,width=1,height=1,class="checkbox",name="frx",label="frx"},
	{x=2,y=0,width=1,height=1,class="checkbox",name="fry",label="fry"},
	}
	presst,rez=aegisub.dialog.display(negdialog,{"OK","Cancel"},{ok='OK',cancel='Cancel'})
	if presst=="Cancel" then aegisub.cancel() end
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	if rez.frz then text=text:gsub("\\frz([%d%.]+)",function(r) return "\\frz"..r-360 end) end
	if rez.frx then text=text:gsub("\\frx([%d%.]+)",function(r) return "\\frx"..r-360 end) end
	if rez.fry then text=text:gsub("\\fry([%d%.]+)",function(r) return "\\fry"..r-360 end) end
	line.text=text
	subs[i]=line
    end
end

function transclip(subs,sel,act)
    line=subs[act]
    text=line.text
    if not text:match("\\i?clip%([%d%.%-]+,") then aegisub.dialog.display({{class="label",
	label="Error: rectangular clip required on active line.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'}) aegisub.cancel() end

    ctype,cc1,cc2,cc3,cc4=text:match("(\\i?clip)%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)%)")

    clipconfig={
    {x=0,y=0,width=2,height=1,class="label",label="   \\clip(", },
    {x=2,y=0,width=3,height=1,class="edit",name="orclip",value=cc1..","..cc2..","..cc3..","..cc4 },
    {x=5,y=0,width=1,height=1,class="label",label=")", },
    {x=0,y=1,width=2,height=1,class="label",label="\\t(\\clip(", },
    {x=2,y=1,width=3,height=1,class="edit",name="klip",value=cc1..","..cc2..","..cc3..","..cc4 },
    {x=5,y=1,width=1,height=1,class="label",label=")", },
    {x=0,y=2,width=5,height=1,class="label",label="Move x and y for new coordinates by:", },
    {x=0,y=3,width=1,height=1,class="label",label="x:", },
    {x=3,y=3,width=1,height=1,class="label",label="y:", },
    {x=1,y=3,width=2,height=1,class="floatedit",name="eks"},
    {x=4,y=3,width=1,height=1,class="floatedit",name="wai"},
    {x=0,y=4,width=5,height=1,class="label",label="Start / end / accel:", },
    {x=1,y=5,width=2,height=1,class="edit",name="accel",value="0,0,1," },
    {x=4,y=5,width=1,height=1,class="checkbox",name="two",label="use next line's clip",value=false,hint="use clip from the next line (line will be deleted)"},
    }
	buttons={"Transform","Calculate coordinates","Cancel"}
	pressed,res=aegisub.dialog.display(clipconfig,buttons,{ok='Transform',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end

	repeat
	    if pressed=="Calculate coordinates" then
		xx=res.eks	yy=res.wai
		for key,val in ipairs(clipconfig) do
		    if val.name=="klip" then val.value=cc1+xx..","..cc2+yy..","..cc3+xx..","..cc4+yy end
		    if val.name=="accel" then val.value=res.accel end
		end	
	pressed,res=aegisub.dialog.display(clipconfig,buttons,{ok='Transform',close='Cancel'})
	    end
	until pressed~="Calculate coordinates"
	if pressed=="Transform" then newcoord=res.klip end
	
    if res.two then
	nextline=subs[act+1]
	nextext=nextline.text
      if not nextext:match("\\i?clip%([%d%.%-]+,") then aegisub.dialog.display({{class="label",
	label="Error: second line must contain a rectangular clip.",x=0,y=0,width=1,height=2}},{"OK"},{close='OK'}) aegisub.cancel()
	else
	nextclip=nextext:match("\\i?clip%(([%d%.%-,]+)%)")
	text=text:gsub("^({\\[^}]*)}","%1\\t("..res.accel..ctype.."("..nextclip..")}")
      end
    else
	text=text:gsub("^({\\[^}]*)}","%1\\t("..res.accel..ctype.."("..newcoord..")}")
    end	
    
    text=text:gsub("0,0,1,\\","\\")
    line.text=text
    subs[act]=line
    if res.two then subs.delete(act+1) end
end

function clone(subs, sel)
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Cloning... %d/%d",x,#sel))
	local line=subs[i]
        local text=subs[i].text
	if not text:match("^{\\") then text=text:gsub("^","{\\}") end

	if res.pos then
		if x==1 then posi=text:match("\\pos%(([^%)]-)%)") end
		if x~=1 and text:match("\\pos") and posi~=nil	 then
		text=text:gsub("\\pos%([^%)]-%)","\\pos%("..posi.."%)")
		end
		if x~=1 and not text:match("\\pos") and not text:match("\\move") and posi~=nil and res.cre then
		text=text:gsub("^{\\","{\\pos%("..posi.."%)\\")
		end
	
		if x==1 then move=text:match("\\move%(([^%)]-)%)") end
		if x~=1 and text:match("\\move") and move~=nil then
		text=text:gsub("\\move%([^%)]-%)","\\move%("..move.."%)")
		end
		if x~=1 and not text:match("\\move") and not text:match("\\pos") and move~=nil and res.cre then
		text=text:gsub("^{\\","{\\move%("..move.."%)\\")
		end
	end
	
	if res.org then
	    if x==1 then orig=text:match("\\org%(([^%)]-)%)") end
	    if x~=1 and orig~=nil then
		if text:match("\\org") then text=text:gsub("\\org%([^%)]-%)","\\org%("..orig.."%)")
		elseif res.cre then text=text:gsub("^({\\[^}]*)}","%1\\org%("..orig.."%)}")
		end
	    end
	end
	
	if res.copyrot then
	    if x==1 then rotz=text:match("\\frz([%d%.%-]+)") end
	    if x==1 then rotx=text:match("\\frx([%d%.%-]+)") end
	    if x==1 then roty=text:match("\\fry([%d%.%-]+)") end
		
	    if x~=1 and text:match("\\frz") and rotz~=nil then text=text:gsub("\\frz[%d%.%-]+","\\frz"..rotz) end
	    if x~=1 and not text:match("\\frz") and rotz~=nil and res.cre then text=text:gsub("^({\\[^}]*)}","%1\\frz"..rotz.."}") end
	    if x~=1 and text:match("\\frx") and rotx~=nil then text=text:gsub("\\frx[%d%.%-]+","\\frx"..rotx) end
	    if x~=1 and not text:match("\\frx") and rotx~=nil and res.cre then text=text:gsub("^({\\[^}]*)}","%1\\frx"..rotx.."}") end
	    if x~=1 and text:match("\\fry") and roty~=nil then text=text:gsub("\\fry[%d%.%-]+","\\fry"..roty) end
	    if x~=1 and not text:match("\\fry") and roty~=nil and res.cre then text=text:gsub("^({\\[^}]*)}","%1\\fry"..roty.."}") end
	end
	
	if res.clip then
	    -- line 1 - copy
	    if x==1 and text:match("\\i?clip") then
		ik,klip=text:match("\\(i?)clip%(([^%)]-)%)")
		if klip:match("m") then type1="vector" else type1="normal" end
	    end
	    -- lines 2+ - paste / replace
	    if x~=1 and text:match("\\i?clip") and klip~=nil then
		ik2,klip2=text:match("\\(i?)clip%(([^%)]-)%)")
		if res.klipmatch then kmatch=ik else kmatch=ik2 end
		if klip2:match("m") then type2="vector" klipv=klip2 else type2="normal" end
		if text:match("\\(i?)clip.-\\(i?)clip") then doubleclip=true ikv,klipv=text:match("\\(i?)clip%((%d?,?m[^%)]-)%)")
		else doubleclip=false end
		if res.combine and type1=="vector" and text:match("\\(i?clip)%(%d?,?m[^%)]-%)") then nklip=klipv.." "..klip else nklip=klip end
		-- 1 clip, stack
		if res.stack and type1~=type2 and not doubleclip then 
		  text=text:gsub("^({\\[^}]*)}","%1\\"..ik.."clip%("..nklip.."%)}")
		-- 2 clips -> not stack
		elseif doubleclip then
		  if type1=="normal" then text=text:gsub("\\(i?clip)%([%d%.,%-]-%)","\\%1%("..nklip.."%)") end
		  if type1=="vector" then text=text:gsub("\\(i?clip)%(%d?,?m[^%)]-%)","\\%1%("..nklip.."%)") end
		-- 1 clip, not stack
		elseif type1==type2 and not doubleclip or not res.stack and not doubleclip then
		  text=text:gsub("\\i?clip%([^%)]-%)","\\"..kmatch.."clip%("..nklip.."%)")
		end
	    end
	    -- lines 2+ / paste / create
	    if x~=1 and not text:match("\\i?clip") and klip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\"..ik.."clip%("..klip.."%)}")
	    end
	end
	
	if res.tclip then
		if x==1 and text:match("\\t%([%d%.,]*\\i?clip") then
		tklip=text:match("\\t%([%d%.,]*\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and tklip~=nil then
		text=text:gsub("\\t%(([%d%.,]*)\\(i?clip)%([^%)]-%)","\\t%(%1\\%2%("..tklip.."%)")
		end
		if x~=1 and not text:match("\\t%([%d%.,]*\\i?clip") and tklip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\t%(\\clip%("..tklip.."%)%)}")
		end
	end

	text=text
	:gsub("\\\\","\\")
	:gsub("\\}","}")
	:gsub("{}","")
	
	line.text=text
	subs[i]=line
    end
    posi, move, orig, klip, tklip=nil
end

function teleport(subs, sel)
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Teleporting... %d/%d",x,#sel))
	local line=subs[i]
        local text=subs[i].text
	xx=res.eks
	yy=res.wai

	if res.tppos then
	    text=text:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)",
	    function(a,b) return "\\pos("..a+xx..","..b+yy..")" end)
	end

	if res.tporg then
	    text=text:gsub("\\org%(([%d%.%-]+),([%d%.%-]+)%)",
	    function(a,b) return "\\org("..a+xx..","..b+yy..")" end)
	end

	if res.tpmov then
	    text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	end

	if res.tpclip then
	    text=text:gsub("clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
	    function(a,b,c,d) return "clip("..a+xx..","..b+yy..","..c+xx..","..d+yy end)
	    
	    if text:match("clip%(m [%d%a%s%-%.]+%)") then
	    ctext=text:match("clip%(m ([%d%a%s%-%.]+)%)")
	    ctext2=ctext:gsub("([%d%-%.]+)%s([%d%-%.]+)",function(a,b) return a+xx.." "..b+yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub("clip%(m "..ctext,"clip(m "..ctext2)
	    end
	    
	    if text:match("clip%(%d+,m [%d%a%s%-%.]+%)") then
	    fac,ctext=text:match("clip%((%d+),m ([%d%a%s%-%.]+)%)")
	    factor=2^(fac-1)
	    ctext2=ctext:gsub("([%d%-%.]+)%s([%d%-%.]+)",function(a,b) return a+factor*xx.." "..b+factor*yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub(",m "..ctext,",m "..ctext2)
	    end
	end

	line.text=text
	subs[i]=line
    end
end

function esc(str)
str=str
:gsub("%%","%%%%")
:gsub("%(","%%%(")
:gsub("%)","%%%)")
:gsub("%[","%%%[")
:gsub("%]","%%%]")
:gsub("%.","%%%.")
:gsub("%*","%%%*")
:gsub("%-","%%%-")
:gsub("%+","%%%+")
:gsub("%?","%%%?")
return str
end

function stylechk(subs,stylename)
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      if stylename==st.name then styleref=st end
    end
    if subs[i].class=="dialogue" then break end
  end
  return styleref
end

function info(subs)
    for i=1,#subs do
      if subs[i].class=="info" then
	    local k=subs[i].key
	    local v=subs[i].value
	    if k=="PlayResX" then resx=v end
	    if k=="PlayResY" then resy=v end
      end
      if subs[i].class=="dialogue" then break end
    end
end

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end

-- The Typesetter's Guide to the Hyperdimensional Relocator.
function guide()
intro="Introduction\n\nHyperdimensional Relocator offers a plethora of functions, \nfocusing primarily on \pos, \move, \org, \clip, and rotations.\nAnything related to positioning, movement, changing shape, etc., \nRelocator aims to make it happen."

cannon="'Align X' means all selected \\pos tags will have the same given X coordinate. Same with 'Align Y' for Y.\n   Useful for multiple signs on screen that need to be aligned horizontally/vertically\n   or mocha signs that should move horizontally/vertically.\n\n'align with first' uses X or Y from the first line.\n\nHorizontal Mirror: Duplicates the line and places it horizontally across the screen, mirrored around the middle.\n   If you input a number, it will mirror around that coordinate instead,\n   so if you have \\pos(300,200) and input is 400, the mirrored result will be \\pos(500,200).\nVertical Mirror is the logical vertical counetrpart.\n\n'rotate mirrors' will flip the text accordingly for the mirror functions.\n\nOrg to Fax: calculates \\fax from the line between \\pos and \\org coordinates.\nClip to Fax: calculates \\fax from the line between the first 2 points of a vectorial clip.\n   Both of these work with \\frz but not with \\frx and \\fry. Also, \\fscx must be the same as \\fscy.\n   See blog post from 2014-03-03 for more info - http://unanimated.xtreemhost.com/itw/tsblok.htm "

travel="'Horizontal' move means y2 will be the same as y1 so that the sign moves in a straight horizontal manner. \nSame principle for 'vertical.'\n\nTransmove: Main function: create \\move from two lines with \\pos.\n   Duplicate your line and position the second one where you want the \\move the end. \n   Script will create \\move from the two positions.\n   Second line will be deleted by default; it's there just so you can comfortably set the final position.\n   Extra function: to make this a lot more awesome, this can create transforms.\n   Not only is the second line used for \\move coordinates, but also for transforms.\n   Any tag on line 2 that's different from line 1 will be used to create a transform on line 1.\n   So for a \\move with transforms you can set the initial sign and then the final sign while everything is static.\n   You can time line 2 to just the last frame. The script only uses timecodes from line 1.\n   Text from line 2 is also ignored (assumed to be same as line 1).\n   You can time line 2 to start after line 1 and check 'keep both.'\n   That way line 1 transforms into line 2 and the sign stays like that for the duration of line 2.\n   'Rotation acceleration' - like with fbf-transform, this ensures that transforms of rotations will go the shortest way,\n   thus going only 4 degrees from 358 to 2 and not 356 degrees around.\n   If the \\pos is the same on both lines, only transforms will be applied.\n   Logically, you must NOT select 2 consecutive lines when you want to run this, \n   though you can select every other line.\n\nMultimove: when first line has \\move and the other lines have \\pos, \\move is calculated from the first line for the others.\n\nShiftmove: like teleporter, but only for the 2nd set of coordinates, ie x2, y2. Uses input from the Teleporter section.\n\nShiftstart: similarly, this only shifts the initial \\move coordinates.\n\nReverse Move: switches the coordinates, reversing the movement direction.\n\nMove Clip: moves regular clip along with \\move using \\t\\clip."

morph="Round Numbers: rounds coordinates for pos, move, org and clip depending on the 'Round' submenu.\n\nJoinfbflines: Select frame-by-frame lines, input numer X when asked, and each X lines will be joined into one.\n   (same way as with \"Join (keep first)\" from the right-click menu)\n      \nKillMoveTimes: nukes the timecodes from a \move tag.\nFullMoveTimes: sets the timecodes for \move to the first and last frame.\nFullTransTimes: sets the timecodes for \\t to the first and last frame.\n\nMove V. Clip: Moves vectorial clip on fbf lines based on \\pos tags.\n   Note: For decimals on v-clip coordinates: xy-vsfilter OK; libass rounds them; regular vsfilter fails completely.\n\nSet Origin: set \\org based off of \\pos using teleporter coordinates.\n\nFReeZe: adds \\frz with the value from the -frz- menu (the only point being that you get exact, round values).\n\nRotate/flip: rotates/flips by 180 dgrees from current value.\n\nNegative rot: keeps the same rotation, but changes to negative number, like 350 -> -10, which helps with transforms.\n\nVector2rect/Rect.2vector: converts between rectangular and vectorial clips.\n\nLetterbreak: creates vertical text by putting a linebreak after each letter.\nWordbreak: replaces spaces with linebreaks."

morph2fbf="Line2fbf:\n\nSplits a line frame by frame, ie. makes a line for each frame.\nIf there's \\move, it calculates \\pos tags for each line.\nIf there are transforms, it calculates values for each line.\nConditions: Only deals with initial block of tags. Works with only one set of transforms.\n   Move and transforms can have timecodes. \n   Missing timecodes will be counted as the ones you get with FullMoveTimes/FullTransTimes.\n   \\fad is now somewhat supported too, but avoid having any alpha transforms at the same time.\n   Timecodes must be exact (even for \\fad, for precision), or the start of the transform/move may be a frame off."

morphorg="Calculate Origin:\n\nThis calculates \\org from a tetragonal vectorial clip you draw.\nDraw a vectorial clip with 4 points, aligned to a surface you need to put your sign on.\nThe script will calculate the vanishing points for X and Y and give you \\org.\nMake the clip as large as you can, since on a smaller one any inaccuracies will be more obvious.\nIf you draw it well enough, the accuracy of the \\org point should be pretty decent.\n(It won't work when both points on one side are lower than both points on the other side.)\nSee blog post from 2013-11-27 for more details: http://unanimated.xtreemhost.com/itw/tsblok.htm"

morphclip="Transform Clip:\n\nGo from \\clip(x1,y1,x2,y2) to \\clip(x1,y1,x2,y2)\\t(\\clip(x3,y3,x4,y4)).\nCoordinates are read from the line.\nYou can set by how much x and y should change, and new coordinates will be calculated.\n\n'use next line's clip' allows you to use clip from the next line.\n   Create a line after your current one (or just duplicate), set the clip you want to transform to on it,\n   and check \"use next line's clip\".\n   The clip from the next line will be used for the transform, and the line will be deleted."

cloan="This copies specified tags from first line to the others.\nOptions are position, move, origin point, clip, and rotations.\n\nreplicate missing tags: creates tags if they're not present\n\nstack clips: allows stacking of 1 normal and 1 vector clip in one line\n\nmatch type: if current clip/iclip doesn't match the first line, it will be switched to match\n\ncv (combine vectors): if the first line has a vector clip, then for all other lines with vector clips \n   the vectors will be combined into 1 clip\n\ncopyrot: copies all rotations"

port="Teleport shifts coordinates for selected tags (\\pos\\move\\org\\clip) by given X and Y values.\nIt's a simple but powerful tool that allows you to move whole gradients, mocha-tracked signs, etc.\n\nNote that the Teleporter fields are also used for some other functions, like Shiftstart and Shiftmove.\nThese functions don't use the 'Teleportation' button but the one for whatever part of HR they belong to."

stg_top={x=0,y=0,width=1,height=1,class="label",
label="The Typesetter's Guide to the Hyperdimensional Relocator.                                                           "}

stg_toptop={x=1,y=0,width=1,height=1,class="label",label="Choose topic below."}
stg_topos={x=1,y=0,width=1,height=1,class="label",label="  Repositioning Field"}
stg_toptra={x=1,y=0,width=1,height=1,class="label",label="          Soul Bilocator"}
stg_toporph={x=1,y=0,width=1,height=1,class="label",label="   Morphing Grounds"}
stg_topseq={x=1,y=0,width=1,height=1,class="label",label="   Cloning Laboratory"}
stg_toport={x=1,y=0,width=1,height=1,class="label",label="           Teleportation"}

stg_intro={x=0,y=1,width=2,height=8,class="textbox",name="gd",value=intro}
stg_cannon={x=0,y=1,width=2,height=11,class="textbox",name="gd",value=cannon}
stg_travel={x=0,y=1,width=2,height=19,class="textbox",name="gd",value=travel}
stg_morph={x=0,y=1,width=2,height=16,class="textbox",name="gd",value=morph}
stg_morph2fbf={x=0,y=1,width=2,height=8,class="textbox",name="gd",value=morph2fbf}
stg_morphorg={x=0,y=1,width=2,height=8,class="textbox",name="gd",value=morphorg}
stg_morphclip={x=0,y=1,width=2,height=8,class="textbox",name="gd",value=morphclip}
stg_cloan={x=0,y=1,width=2,height=9,class="textbox",name="gd",value=cloan}
stg_port={x=0,y=1,width=2,height=8,class="textbox",name="gd",value=port}

cp_main={"Positron Cannon","Hyperspace Travel","Metamorphosis","Cloning Sequence","Teleportation","Disintegrate"}
cp_back={"Warp Back"}
cp_morph={"Warp Back","Metamorphosis","Line2fbf","Calculate Origin","Transform Clip"}
esk1={close='Disintegrate'}
esk2={cancel='Warp Back'}
stg={stg_top,stg_toptop,stg_intro} control_panel=cp_main esk=esk1
repeat
	stg={stg_top,stg_toptop,stg_intro} control_panel=cp_main esk=esk1
	if press=="Positron Cannon" then 	stg={stg_top,stg_topos,stg_cannon} control_panel=cp_back esk=esk2 end
	if press=="Hyperspace Travel" then 	stg={stg_top,stg_toptra,stg_travel} control_panel=cp_back esk=esk2 end
	if press=="Metamorphosis" then 	stg={stg_top,stg_toporph,stg_morph} control_panel=cp_morph esk=esk2 end
	if press=="Cloning Sequence" then 	stg={stg_top,stg_topseq,stg_cloan} control_panel=cp_back esk=esk2 end
	if press=="Teleportation" then 	stg={stg_top,stg_toport,stg_port} control_panel=cp_back esk=esk2 end
	if press=="Line2fbf" then 		stg={stg_top,stg_toporph,stg_morph2fbf} control_panel=cp_morph esk=esk2 end
	if press=="Calculate Origin" then 	stg={stg_top,stg_toporph,stg_morphorg} control_panel=cp_morph esk=esk2 end
	if press=="Transform Clip" then 	stg={stg_top,stg_toporph,stg_morphclip} control_panel=cp_morph esk=esk2 end
	if press=="Warp Back" then 		stg={stg_top,stg_toptop,stg_intro} control_panel=cp_main esk=esk1 end
press,rez=aegisub.dialog.display(stg,control_panel,esk)
until press=="Disintegrate"
if press=="Disintegrate" then aegisub.cancel() end
end

function relocator(subs,sel,act)
rin=subs[act]	tk=rin.text
if tk:match"\\move" then 
m1,m2,m3,m4=tk:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)") M1=m3-m1 M2=m4-m2 mlbl="mov: "..M1..","..M2
else mlbl="" end
hyperconfig={
    {x=10,y=0,width=3,height=1,class="label",label="Teleportation"},
    {x=10,y=1,width=3,height=1,class="floatedit",name="eks",hint="X"},
    {x=10,y=2,width=3,height=1,class="floatedit",name="wai",hint="Y"},

    {x=0,y=0,width=2,height=1,class="label",label="Repositioning Field",},
    {x=0,y=1,width=1,height=1,class="dropdown",name="posi",items={"Align X","Align Y","org to fax","clip to fax","horizontal mirror","vertical mirror"},value="Align X",},
    {x=0,y=2,width=1,height=1,class="floatedit",name="post",value=0},
    {x=0,y=3,width=1,height=1,class="checkbox",name="first",label="align with first",value=align_with_first,},
    {x=0,y=4,width=1,height=1,class="checkbox",name="mirr",label="rotate mirrors",value=false,},
    {x=0,y=5,width=1,height=1,class="checkbox",name="space",label="space travel guide",value=false,},
    
    {x=2,y=0,width=2,height=1,class="label",label="Soul Bilocator"},
    {x=2,y=1,width=1,height=1,class="dropdown",name="move",
	items={"transmove","horizontal","vertical","multimove","rvrs. move","shiftstart","shiftmove","move clip"},value="transmove",},
    {x=2,y=2,width=1,height=1,class="checkbox",name="keep",label="keep both",value=keep_both,hint="keeps both lines for transmove"},
    {x=2,y=3,width=3,height=1,class="checkbox",name="rot",label="rotation acceleration",value=rotation_acceleration,hint="transmove option"},
    {x=2,y=5,width=3,height=1,class="label",name="moo",label=mlbl},
    
    {x=4,y=0,width=2,height=1,class="label",label="Morphing Grounds",},
    {x=4,y=1,width=2,height=1,class="dropdown",name="mod",
	items={"round numbers","line2fbf","join fbf lines","killmovetimes","fullmovetimes","fulltranstimes","move v. clip","set origin","calculate origin","transform clip","FReeZe","rotate 180","flip hor.","flip vert.","negative rot","vector2rect.","rect.2vector","letterbreak","wordbreak"},value="round numbers"},
    {x=4,y=2,width=1,height=1,class="label",label="Round:",},
    {x=5,y=2,width=1,height=1,class="dropdown",name="rnd",items={"all","pos","move","org","clip"},value="all"},
    {x=5,y=3,width=1,height=1,class="dropdown",name="freeze",
	items={"-frz-","30","45","60","90","120","135","150","180","-30","-45","-60","-90","-120","-135","-150"},value="-frz-"},
    {x=4,y=4,width=2,height=1,class="checkbox",name="delfbf",label="delete l2fbf orig.",value=delete_orig_line_in_line2fbf,hint="delete the original line for line2fbf"},
    
    {x=6,y=0,width=3,height=1,class="label",label="Cloning Laboratory",},
    {x=6,y=1,width=2,height=1,class="checkbox",name="pos",label="\\posimove",value=cc_posimove },
    {x=8,y=1,width=1,height=1,class="checkbox",name="org",label="\\org",value=cc_org },
    {x=6,y=2,width=1,height=1,class="checkbox",name="clip",label="\\[i]clip",value=cc_clip },
    {x=7,y=2,width=2,height=1,class="checkbox",name="tclip",label="\\t(\\[i]clip)",value=cc_tclip },
    {x=6,y=5,width=4,height=1,class="checkbox",name="cre",label="replicate missing tags",value=cc_replicate_tags },
    {x=6,y=3,width=2,height=1,class="checkbox",name="stack",label="stack clips",value=cc_stack_clips },
    {x=6,y=4,width=1,height=1,class="checkbox",name="copyrot",label="copyrot",value=cc_copy_rotations,hint="Cloning - copy rotations" },
    {x=8,y=3,width=3,height=1,class="checkbox",name="klipmatch",label="match type    ",value=cc_match_clip_type },
    {x=8,y=4,width=3,height=1,class="checkbox",name="combine",label="comb. vect.",value=cc_combine_vectors,hint="Cloning - combine vectors" },
    
    {x=11,y=3,width=1,height=1,class="checkbox",name="tppos",label="pos",value=tele_pos },
    {x=11,y=4,width=1,height=1,class="checkbox",name="tpmov",label="move",value=tele_move },
    {x=12,y=3,width=1,height=1,class="checkbox",name="tporg",label="org",value=tele_org },
    {x=12,y=4,width=1,height=1,class="checkbox",name="tpclip",label="clip",value=tele_clip },
    {x=11,y=5,width=2,height=1,class="label",label="HR version: "..script_version,},
} 

	pressed,res=aegisub.dialog.display(hyperconfig,
	{"Positron Cannon","Hyperspace Travel","Metamorphosis","Cloning Sequence","Teleportation","Disintegrate"},{cancel='Disintegrate'})
	
	ms2fr=aegisub.frame_from_ms
	fr2ms=aegisub.ms_from_frame
	keyframes=aegisub.keyframes()
		
	if pressed=="Disintegrate" then aegisub.cancel() end
	if pressed=="Positron Cannon" then if res.space then guide(subs,sel) else sel=positron(subs, sel) end end
	if pressed=="Hyperspace Travel" then
	    if res.move=="multimove" then multimove (subs, sel) else bilocator(subs, sel) end
	end
	if pressed=="Metamorphosis" then
	    aegisub.progress.title(string.format("Morphing..."))
	    if res.mod=="line2fbf" then movetofbf(subs, sel) 
	    elseif res.mod=="transform clip" then transclip(subs, sel, act)
	    elseif res.mod=="join fbf lines" then joinfbflines(subs, sel)
	    elseif res.mod=="negative rot" then negativerot(subs, sel)
	    else modifier(subs, sel) end
	end
	if pressed=="Cloning Sequence" then clone(subs, sel) end
	if pressed=="Teleportation" then teleport(subs, sel) end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, relocator)