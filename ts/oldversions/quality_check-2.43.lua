﻿script_name="Quality Check"
script_description="Quality Check"
script_author="unanimated"
script_version="2.43"

require "clipboard"

function qc(subs, sel)

sorted=0	mblur=0		layer=0		malf=0		inside=0	comment=0	dialog=0	bloped=0	contr=0	
dis=0		over=0		gap=0		dspace=0	dword=0		outside=0	op=0		ed=0		sign=0
italics=0	lbreak=0	hororifix=0	zeroes=0	badita=0	dotdot=0	comfail=0	oneframe=0	trf=0
zerot=0		halfsek=0	readableh=0	unreadable=0	saurosis=0	dupli=0		negadur=0	empty=0		orgline=0
tdura=0		tlength=0	tcps=0		trilin=0	report=""	styles=""	misstyles=""	fontlist=""	fontable={}

  if pressed=="Clear QC" then
    for i=1, #subs do
        if subs[i].class=="dialogue" then
            local line=subs[i]
		line.actor=line.actor
		:gsub("%s?%.%.%.timer pls","")
		:gsub("%s?%[time gap %d+ms%]","")
		:gsub("%s?%[overlap %d+ms%]","")
		:gsub("%s?%[negative duration%]","")
		:gsub("%s?%[zero time%]","")
		:gsub("%s?%[0 time%]","")
		line.effect=line.effect
		:gsub("%s?%[malformed tags%]","")
		:gsub("%s?%[disjointed tags%]","")
		:gsub("%s?%[redundant tags%]","")
		:gsub("%s?%.%.%.sort by time pls","")
		:gsub("%s?%[doublespace%]","")
		:gsub("%s?%[double word%]","")
		:gsub("%s?%[italics fail%]","")
		:gsub(" {\\Stupid","")
		:gsub("%s?%[stupid contractions%]","")
		:gsub("%s?%-MISSING BLUR%-","")
		:gsub("%s?%[%.%.%]","")
		:gsub("%s?%[hard to read%??%]","")
		:gsub("%s?%[unreadable.*%]","")
		:gsub("%s?%[UNREADABLE!+%]","")
		:gsub("%s?%[under 0%.5s%]","")
		:gsub("%s?%[3%-liner%]","")
		:gsub("%s?%[\"%]","")
            subs[i]=line
        end
    end
  end

  if pressed==">QC" then

    -- make list of styles and fonts
    stitle,video,colorspace,resx,resy=nil
      styletab={}
    for i=1,#subs do
      aegisub.progress.title(string.format("Checking styles/info: %d/%d",i,#subs))
      if subs[i].class=="style" then
	table.insert(styletab,subs[i])
	if subs[i].name=="Default" then dstyleref=subs[i] end
	fname=subs[i].fontname
	fnam=esc(fname)
 	if not fontlist:match(fnam) then fontlist=fontlist..fname.."\n" table.insert(fontable,fname) end
	styles=styles..subs[i].name..", "
	redstyles=styles
      end
      if subs[i].class=="info" then
	    local k=subs[i].key
	    local v=subs[i].value
	    if k=="Title" then stitle=v end
	    if k=="Video File" then video=v end
	    if k=="YCbCr Matrix" then colorspace=v end
	    if k=="PlayResX" then resx=v end
	    if k=="PlayResY" then resy=v end
      end
      if subs[i].class=="dialogue" then break end
    end
    
    if res.distill=="" then distill="xxxxxxxx" else distill=res.distill end

    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	local style=line.style
	local effect=line.effect
	local actor=line.actor
	if style:match("Defa") or style:match("Alt") or style:match("[Oo]verlap") or style:match(distill) then def=1 else def=0 end
	if style:match("^OP") or style:match("^ED") then oped=1 else oped=0 end
	
	visible=text:gsub("{\\alpha&HFF&}[^{}]-({[^}]-\\alpha&H)","%1")	:gsub("{\\alpha&HFF&}[^{}]*$","")	:gsub("{[^{}]-}","")
			:gsub("\\[Nn]","*")	:gsub("%s?%*+%s?"," ")	:gsub("^%s+","")	:gsub("%s+$","")
	if text:match("{\\alpha&HFF&}") then alfatime=1 else alfatime=0 end
	nocomment=text:gsub("{[^\\}]-}","")
	cleantxt=text:gsub("{[^}]-}","")
	onlytags=nocomment:gsub("}[^{]-{","}{")	:gsub("}[^{]+$","}")	:gsub("^[^{]+$","")
	parenth=onlytags:gsub("[^%(%)]","")		:gsub("%(%(%)%)","")	:gsub("%(%)","")
	start=line.start_time
	endt=line.end_time
	if i<#subs then nextline=subs[i+1] end
	prevline=subs[i-1]
	if prevline.class=="dialogue" then prevcleantxt=prevline.text:gsub("{[^}]-}","") else prevcleantxt="" end
	prevstart=prevline.start_time
	prevend=prevline.end_time
	dura=endt-start
	dur=dura/1000
	char=visible:gsub(" ","")	:gsub("[%.,\"]","")
	linelen=char:len()
	rawcps=(linelen/dur)
	cps=math.ceil(linelen/dur)
	
	-- check if sorted by time		[All lines]
	if res["sorted"] then
	if prevline.class=="dialogue" and start<prevstart then
	    effect=effect.." ...sort by time pls" sorted=1
	end	end

      if not line.comment and line.effect~="qcd" then
	-- check for blur			[non-default]
	if res["blur"] and def==0 and visible~="" and not text:match("\\blur") and not text:match("\\be") and endt>0 then
		if res.bloped then  
		  effect=effect.." -MISSING BLUR-" mblur=mblur+1
		  if oped==1 then bloped=bloped+1 end
		else
		  if oped==0 then effect=effect.." -MISSING BLUR-" mblur=mblur+1 end
		end
	end

	-- check for malformed tags		[All lines]
	if res["malformed"] then
	if text:match("{[^}]-\\\\[^}]-}")
	or text:match("\\}")  
	or text:match("\\blur%.") 
	or text:match("\\bord%.") 
	or text:match("\\shad%.")
	or text:match("\\alpha[^&\\}]")
	or text:match("\\alpha&[^H]")
	or text:match("\\alpha&H%x[^%x]")
	or text:match("\\alpha&H%x%x[^&]")
	or text:match("\\fad%([%d,]-[^%d,][%d,]-%)")
	or text:match("\\pos%([%d,%.]-[^%d,%.][%d,%.]-%)")
	or text:match("\\move%([%d,%.]-[^%d,%.][%d,%.]-%)")
	or text:match("\\org%([%d,%.]-[^%d,%.][%d,%.]-%)")
	or text:match("\\[1234]a[^&\\}]")
	or text:match("\\[1234]a&[^H]")
	or text:match("\\[1234]c[^&\\}]")
	or text:match("\\[1234]?c&[^H]")
	or text:match("\\[1234]?c&%x%x%x%x%x%x[^&]")
	or text:match("{\\[^}]*&&[^}]*}")
	or parenth~=""
	then effect=effect.." [malformed tags]" malf=malf+1 end
	clrfail=0
	for clr in text:gmatch("c&H(%x+)&") do
	if clr:len()~=6 then clrfail=1 end	end
	if clrfail==1 then effect=effect.." [malformed tags]" malf=malf+1 end
	end

	-- check for disjointed tags		[All lines]
	if res["disjointed"] then
	if text:match("{\\[^}]*}{\\[^}]*}") and not text:match("}{\\k")
	then effect=effect.." [disjointed tags]" dis=dis+1 end
	end

	-- check for overlaps and gaps		[Default]
	if res["overlap"] then
	if prevline.class=="dialogue" and style:match("Defa") and prevline.style:match("Defa") 
	and text:match("\\an8")==nil and prevline.text:match("\\an8")==nil and prevline.comment==false then
		if start<prevend and prevend-start<500 and endt-prevend~=0 then 
		actor=actor.." [overlap "..prevend-start.."ms]" over=over+1 
			if prevend-start<100 then actor=actor.." ...timer pls" end
		end
		if start>prevend and start-prevend<200 then 
		actor=actor.." [time gap "..start-prevend.."ms]" gap=gap+1 
			if start-prevend<100 then actor=actor.." ...timer pls" end
		end
		if endt==start and endt>0 and visible~="" then actor=actor.." [zero time]" zerot=zerot+1 end
		if endt<start then actor=actor.." [negative duration]" negadur=negadur+1 end
	end	end

	-- check dialogue layer			[Dialogue]
	if res["dlayer"] then
	if def==1 and line.layer==0 then layer=layer+1 
	end	end
	
	-- check for 3-liners			[Dialogue]
	if res.tril and def==1 then
	if style=="Default" then styleref=dstyleref else styleref=stylechk(subs,line.style) end
	if styleref==nil then aegisub.log("\n    !! STYLE \""..style.."\" IS MISSING !!") end
	xres,yres=aegisub.video_size()
	if xres==nil then xres=resx yres=resy end
	realx=xres/yres*resy
	wf=realx/resx
	vidth=realx-(styleref.margin_l*wf)-(styleref.margin_r*wf)
	width=aegisub.text_extents(styleref,cleantxt)
	  if width>vidth and not cleantxt:match("\\N") then 
	  if text:match("^{[^}]*\\i1") and not text:match("\\i0") then styleref.italic=true end
	  tekst="\\N"..cleantxt
	  diff=3000	stop=0
	    while stop==0 do
	      last=btxt
	      lastwb=wb
	      lastwa=wa
	      tekst=tekst:gsub("\\N([^%s{}]+%s)","%1\\N")
	      btxt=tekst:gsub(" \\N","\\N")
	      bspace=btxt:match("^(.-)\\N")
	      aspace=btxt:match("\\N(.-)$")
	      wb=aegisub.text_extents(styleref,bspace)
	      wa=aegisub.text_extents(styleref,aspace)
	      tdiff=math.abs(wb-wa)
	      if tdiff<diff then diff=tdiff else 
	        stop=1 btxt=last 
	      end
	    end
	    if lastwb>=vidth or lastwa>=vidth then trilin=trilin+1 effect=effect.." [3-liner]" end
	  end
	  if cleantxt:match("\\N") then btxt=cleantxt 
	    if text:match("^{[^}]*\\i1") and not text:match("\\i0") then styleref.italic=true end
	    bspace=btxt:match("^(.-)\\N")  aspace=btxt:match("\\N(.-)$")
	    wb=aegisub.text_extents(styleref,bspace)
	    wa=aegisub.text_extents(styleref,aspace)
	    if wb>=vidth or wa>=vidth then trilin=trilin+1 effect=effect.." [3-liner]" end
	  end
	end

	-- check for double spaces in dialogue		[Dialogue]
	if res["doublespace"] and def==1 then
		if visible:match("%s%s") then effect=effect.." [doublespace]" dspace=dspace+1 end
	end

	-- check for double words			[Dialogue]
	if res["doubleword"] and def==1 then
	visible2w=visible.."."
	    for derp in visible2w:gmatch("%s?([%w%s\']+)[%p]") do
	    derp2=derp:gsub("^[%a\']+","")
		for a,b in derp:gmatch("([%a\']+)%s([%a\']+)") do
		if a==b and not a:match("^%u") then effect=effect.." [double word]" dword=dword+1 end
		end
		for a,b in derp2:gmatch("([%a\']+)%s([%a\']+)") do
		if a==b and not a:match("^%u") then effect=effect.." [double word]" dword=dword+1 end
		end
	    end
	end

	-- check for fucked up comments			[All lines]
	if visible:match("[{}]") or text:match("}[^{]-}") or text:match("{[^}]-{") then comfail=comfail+1 effect=effect.." {\\Stupid" end

	-- check for bad italics - {\i1}   {\i1}
	if res.failita and not text:match("\\r") then
	  itafail=0
	  itl=""
	  for it in text:gmatch("\\i([01]?)[\\}]") do 
	    if it=="" then styleref=stylechk(subs,line.style)
	      if styleref.italics then it="1" else it="0" end
	    end
	  itl=itl..it end
	  if itl:match("11") or itl:match("00") then itafail=1 end
	  if itafail==1 then effect=effect.." [italics fail]" badita=badita+1 end
	end

	-- check readability	(some sentences are much harder to read than others, so don't take this too seriously, but over 25 is probably bad.)
	ll=linelen ra=0
	if res.read and def==1 and dura>50 and alfatime==0 and prevcleantxt~=cleantxt then		-- these could use rephrasing if possible
	  if cps==23 and ll>60 then effect=effect.." [hard to read?]" ra=1 end
	  if cps>23 and cps<=26 then 
	    if ll>25 and ll<100 then effect=effect.." [hard to read?]" ra=1 end
	    if ll>=100 then effect=effect.." [hard to read]" ra=1 end
	  end
	  if cps>26 and cps<30 and ll<=30 then effect=effect.." [hard to read?]" ra=1 end
	end
	
	if res.noread and def==1 and dura>50 and alfatime==0 and prevcleantxt~=cleantxt then	-- from here on, it's bad. rephrase/retime
	  if cps>26 and cps<30 then
	    if ll>30 and ll<=60 then effect=effect.." [unreadable]" ra=2 end
	    if ll>60 then effect=effect.." [unreadable!]" ra=2 end
	  end
	  if cps>=30 and cps<=35 then 
	    if ll<=30 then effect=effect.." [unreadable]" ra=2 end
	    if ll>30 and ll<=60 then effect=effect.." [unreadable!]" ra=2 end
	    if ll>60 then effect=effect.." [unreadable!!]" ra=2 end
	  end
	  if cps>35 then effect=effect.." [UNREADABLE!!]" ra=2 end			-- timer and editor need to be punched
	end
	if ra==1 then readableh=readableh+1 end
	if ra==2 then unreadable=unreadable+1 end

	-- check for double periods		[Dialogue]
	if def==1 then
	if visible:match("[^%.]%.%.[^%.]") or visible:match("[^%.]%.%.$") then effect=effect.." [..]" dotdot=dotdot+1 end
	end

	-- check for periods/commas inside/outside quotation marks	[All lines]
	if not visible:match("^\"[^\"]+\"$") and not visible:match("^[^\"]+[%.%?!]%s\"%u[^\"]+\"$") then
	if visible:match("[^%.][%.,]\"") then inside=inside+1 if res.quot then effect=effect.." [\"]" end end
	if visible:match("\"[%.,][^%.]") or visible:match("\"[%.,]$") then outside=outside+1 if res.quot then effect=effect.." [\"]" end end
	end

	-- check for redundant tags		[All lines]
	if res.redundant then dup=0
	tags1={"blur","be","bord","shad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay","c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	  for tax in text:gmatch("({\\[^}]-})") do
	    for i=1,#tags1 do
	      tag=tags1[i]
	      if not tax:match("\\t") and tax:match("\\"..tag.."[%d%-&][^}]-\\"..tag.."[%d%-&]") then dup=1 end
	    end
	  end
	if text:match("{\\[^}]-}$") then dup=1 end
	if dup==1 then dupli=dupli+1 effect=effect.." [redundant tags]" end
	end

	-- lines under 0.5s			[Dialogue]
	if res.halfsec and def==1 and visible~="" and ll>8 and prevcleantxt~=cleantxt then
	if dura<500 and dura>50 then halfsek=halfsek+1 effect=effect.." [under 0.5s]" end
	end

	-- Hdr request against jdpsetting	[All lines]
	if text:match("{\\an8\\bord[%d%.]+\\pos%([%d%.%,]*%)}") then actor=" What are you doing..." end
	
	if visible:match("embarass") then effect=effect.." how embarrassing" end
	
	if visible:match(" a women ") then effect=effect.." a what?" end
	
	if visible:match("'ve have") then effect=effect.." Now you've have done it!" end
	
	-- retarded / pointless contractions that sound the same as not contracted / are unpronounceable
	if visible:match("[wt]here're") or visible:match("this'[sd]")  or visible:match("when'[drv]")
	or visible:match("guys'[rv]e") or visible:match("ll've")
	then contr=contr+1 effect=effect.." [stupid contractions]" end
	
	-- count OP lines
	if style:match("^OP") then op=op+1 end
	
	-- count ED lines
	if style:match("^ED") then ed=ed+1 end
	
	-- count what's probably signs
	if def==0 and oped==0 then sign=sign+1 end 
	
	-- count linebreaks in dialogue
	if res["lbreax"] and def==1 and nocomment:match("\\N") then lbreak=lbreak+1 end
	
	-- count lines with italics
	if res["italix"] and def==1 and text:match("\\i1") then italics=italics+1 end
	
	-- count honorifics			[Dialogue]
	if res["honorifix"] and def==1 then
		if visible:match("%a%-san[^%a]") or visible:match("%a%-kun[^%a]") or visible:match("%a%-chan[^%a]")
		or visible:match("%a%-sama[^%a]") or visible:match("%a%-se[mn]pai") or visible:match("%a%-dono")
		or visible:match("%a%-sensei") then hororifix=hororifix+1 end
	end
	
	-- count lines with 0 time		[All lines]
	if res["zero"] then
	  if endt==start then zeroes=zeroes+1 actor=actor.." [0 time]" end
	end
	
	-- check for missing styles		[All lines]
	sty=esc(style)
	if res.mistyle and not styles:match(sty) and not misstyles:match(sty) then misstyles=misstyles..style..", " end
	
	-- list unused styles			[All lines]
	if res.uselesstyle then --aegisub.log("\nsty "..sty)
	    if redstyles:match("^"..sty..",") or redstyles:match(", "..sty..",") then 
	    redstyles=redstyles:gsub("^"..sty..", ","") redstyles=redstyles:gsub(", "..sty..", ",", ") end
	end
	
	-- collect font names			[All lines]
	if res.fontcheck and text:match("\\fn") then 
	    for fontname in text:gmatch("\\fn([^}\\]+)") do
	    fname=esc(fontname)
	    if not fontlist:match(fname) then fontlist=fontlist..fontname.."\n" table.insert(fontable,fontname) end
	    end
	end

	-- count dialogue lines
	if def==1 then dialog=dialog+1 end
	
	-- count lines lasting 1 frame
	if dura<=50 and dura>0 then oneframe=oneframe+1 end
	
	-- longest dialogue line: characters
	if def==1 and linelen>tlength then tlength=linelen longtext=visible end
	if longtext==nil then longtext="[No dialogue lines with text]" tlength=0 end
	
	-- longest dialogue line: duration
	if def==1 and visible~="" and dura>tdura then tdura=dura ldura=dura/1000 longline=visible end
	if longline==nil then longline="[No dialogue lines with text]" ldura=0 end
	
	-- dialogue line with highest CPS
	if def==1 and dura>50 and alfatime==0 and prevcleantxt~=cleantxt and rawcps>tcps then tcps=cps highcps=visible cpstime=dura/1000 end
	if highcps==nil then highcps="[No dialogue lines with text]" tcps=0 cpstime=0 end
	
	-- lines with transforms
	if text:match("\\t%(") then trf=trf+1 end
	
	-- lines with \org
	if text:match("\\org%(") then orgline=orgline+1 end
	
	-- empty lines
	if text=="" then empty=empty+1 end
	
      end
	
	-- count commented lines
	if line.comment==true then comment=comment+1 end
	
	-- faggosaurosis count
	if res.sauro then
	  if line.effect~=effect and effect~=" [\"]" or line.actor~=actor then saurosis=saurosis+1 end
	end
	
	line.actor=actor
	line.effect=effect
	line.text=text
        subs[i]=line
	aegisub.progress.title(string.format("Checking line: %d/%d",x,#sel))
    end
    aegisub.progress.title(string.format("Processing data..."))
    if stitle~=nil then report=report.."Script Title:	"..stitle.."\n" end
    if video~=nil then report=report.."Video File:	"..video.."\n" end
    if colorspace~=nil then report=report.."Colorspace:	"..colorspace.."\n" end
    if resx~=nil then report=report.."Script Resolution:	"..resx.."x"..resy.."\n\n" end
    exportfonts="" table.sort(fontable)
	for f=1,#fontable do
	exportfonts=exportfonts..fontable[f]..", "
	end
	exportfonts=exportfonts:gsub(", $","")
	redstyles=redstyles:gsub(", $","")
    
    if #sel==1 then  report=report.."Selection: "..#sel.." line,   "
    else report=report.."Selection: "..#sel.." lines,   " end
    report=report.."Commented: "..comment.."\n"
    report=report.."Dialogue: "..dialog..",   OP: "..op..",   ED: "..ed..",   TS: "..sign.."\n\n"
    if res["lbreax"] then report=report.."Dialogue lines with linebreaks... "..lbreak.."\n" end
    if res["italix"] then report=report.."Dialogue lines with italics tag... "..italics.."\n" end
    if res["honorifix"] then report=report.."Honorifics found... "..hororifix.."\n" end
    if res["zero"] then report=report.."Lines with zero time... "..zeroes.."\n" end
    if res["empty"] then report=report.."Empty lines... "..empty.."\n" end
    if res["oneframe"] then report=report.."Lines lasting one frame... "..oneframe.."\n" end
    if res["transline"] then report=report.."Lines with transforms... "..trf.."\n" end
    if res["orgline"] then report=report.."Lines with \\org... "..orgline.."\n" end
    if res["longtext"] then report=report.."Dialogue line with longest text:\n \""..longtext.."\" - "..tlength.." characters\n" end
    if res["longline"] then report=report.."Dialogue line with longest duration:\n \""..longline.."\" - "..ldura.."s\n" end
    if res["highcps"] then report=report.."Dialogue line with highest CPS:\n \""..highcps.."\" - "..tcps.." CPS / "..cpstime.."s\n" end
    
    if res["uselesstyle"] and redstyles~="" then report=report.."\nRedundant (unused) styles: "..redstyles.."\n" end
    if res["fontcheck"] then report=report.."\nUsed fonts ("..#fontable.."): "..exportfonts.."\n" end
    report=report.."\n\n----------------  PROBLEMS FOUND ----------------\n\n"
    if sorted==1 then report=report.."NOT SORTED BY TIME.\n" end
    if colorspace=="TV.601" then report=report.."COLORSPACE IS TV.601. Use TV.709 or Daiz will haunt you!\n" end
    if misstyles~="" then misstyles=misstyles:gsub(", $","") report=report.."MISSING STYLES: "..misstyles.."\n" end
    if mblur~=0 then report=report.."Non-dialogue lines with missing blur... "..mblur.."\n" end
    if bloped~=0 then report=report.."Out of those OP/ED... "..bloped.."\n" end
    if malf~=0 then report=report.."Lines with malformed tags... "..malf.."\n" end
    if dis~=0 then report=report.."Lines with disjointed tags... "..dis.."\n" end
    if dupli~=0 then report=report.."Lines with redundant tags... "..dupli.."\n" end
    if trilin~=0 then report=report.."THREE-LINERS... "..trilin.."\n" end
    if over~=0 then report=report.."Suspicious timing overlaps... "..over.."\n" end
    if gap>9 then gapu="  --  Timer a shit" else gapu="" end
    if gap~=0 then report=report.."Suspicious gaps in timing (under 200ms)... "..gap..gapu.."\n" end
    if zerot~=0 then report=report.."Lines with text but zero time... "..zerot.."\n" end
    if negadur~=0 then report=report.."Lines with negative duration... "..negadur.."\n" end
    if dspace~=0 then report=report.."Dialogue lines with double spaces... "..dspace.."\n" end
    if dword~=0 then report=report.."Dialogue lines with a double word... "..dword.."\n" end
    if dotdot~=0 then report=report.."Dialogue lines with double periods... "..dotdot.."\n" end
    if halfsek~=0 then report=report.."Dialogue lines under 0.5s... "..halfsek.."\n" end
    if readableh~=0 then report=report.."Lines that may be hard to read... "..readableh.."\n" end
    if unreadable>9 then unrdbl="  --  Editor a shit" else unrdbl="" end
    if unreadable~=0 then report=report.."Lines that may be impossible to read and should be edited or retimed... "..unreadable..unrdbl.."\n" end
    if badita~=0 then report=report.."Lines with bad italics... "..badita.."\n" end
    if contr~=0 then report=report.."Stupid / pointless contractions... "..contr.."\n" end
    if comfail~=0 then report=report.."Fucked up braces... "..comfail.."\n" end
    if inside~=0 and outside~=0 then 
    report=report.."Comma/period inside quotation marks... "..inside.."\n"
    report=report.."Comma/period outside quotation marks... "..outside.."\n" end
    if saurosis>0 and saurosis<100 then report=report.."Total lines with faggosaurosis... "..saurosis.."\n" end
    if saurosis>99 and saurosis<500 then report=report.."Total lines with faggosaurosis... "..saurosis.." -- You're doing it wrong!\n" end
    if saurosis>499 then report=report.."Total lines with faggosaurosis... "..saurosis.." -- WARNING: YOUR FAGGOSAUROSIS LEVELS ARE TOO HIGH!\n" end
    if layer~=0 and sign ~=0 and #sel>dialog then report=report.."Dialogue may overlap with TS. Set to higher layer to avoid.\n" end
    if sorted==0 and mblur==0 and malf==0 and dis==0 and over==0 and gap==0 and dspace==0 and dotdot==0 and badita==0 and comfail==0 and unreadable==0 and misstyles=="" and colorspace~="TV.601" then
    report=report.."\nCongratulations. No serious problems found." else
    if saurosis<500 then report=report.."\nPlease fix the problems and try again." end
    if saurosis>499 then report=report.."\nWHAT ARE YOU DOING?! FIX THAT SHIT, AND DON'T FUCK IT UP AGAIN NEXT TIME!" end
    end
    brcount=0
    for brk in report:gmatch("\n") do brcount=brcount+1 end
    aegisub.progress.title(string.format("Done"))
        reportdialog=
	{{x=0,y=0,width=50,height=1,class="label",label="Text to export:"},
	{x=0,y=1,width=50,height=brcount/2+6,class="textbox",name="copytext",value=report},}
    pressd,rez=aegisub.dialog.display(reportdialog,{"OK","Copy to clipboard","Cancel"},{ok='OK',close='Cancel'})
    if pressd=="Copy to clipboard" then clipboard.set(report) end	if pressd=="Cancel" then aegisub.cancel() end
  end
end

function dial5(subs)
    for i=1, #subs do
      if subs[i].class=="dialogue" then
	local line=subs[i]
	if line.style:match("Defa") or line.style:match("Alt") or line.style:match("Main") then
	  if line.layer<5 then line.layer=line.layer+5 end
	end
	subs[i]=line
      end
    end
end

function stylechk(stylename)
    for i=1,#styletab do
	if stylename==styletab[i].name then
	    styleref=styletab[i]
	    if styletab[i].name=="Default" then defaref=styletab[i] end
	end
    end
    return styleref
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

function konfig(subs, sel)
	dialog_config=
	{
	{x=1,y=0,width=1,height=1,class="label",label="Note: Dialogue styles must match 'Defa' or 'Alt' or: "},
	{x=2,y=0,width=1,height=1,class="edit",name="distill",},
	{x=1,y=1,width=1,height=1,class="label",label="Analysis [applies to SELECTED lines]:"   },
        {x=1,y=2,width=1,height=1,class="checkbox",name="sorted",label="Check if sorted by time",value=true},
	{x=1,y=3,width=1,height=1,class="checkbox",name="blur",label="Check for missing blur in signs",value=true},
	{x=1,y=4,width=1,height=1,class="checkbox",name="bloped",label="Check for missing blur in OP/ED",value=true},
	
	{x=1,y=5,width=1,height=1,class="checkbox",name="overlap",label="Check for overlaps / gaps / zero-time lines",value=true},
	{x=1,y=6,width=1,height=1,class="checkbox",name="malformed",label="Check for malformed tags - \\blur.5, \\alphaFF, \\\\",value=true},
	{x=1,y=7,width=1,height=1,class="checkbox",name="disjointed",label="Check for disjointed tags - {\\tags...}{\\tags...}",value=true},
	{x=1,y=8,width=1,height=1,class="checkbox",name="doublespace",label="Check for double spaces in dialogue",value=true},
	{x=1,y=9,width=1,height=1,class="checkbox",name="doubleword",label="Check for double words in dialogue",value=true},
	{x=1,y=10,width=1,height=1,class="checkbox",name="tril",label="Check for three-liners (slowish)",value=true},
	{x=1,y=11,width=1,height=1,class="checkbox",name="read",label="Check for hard-to-read lines",value=true},
	{x=1,y=12,width=1,height=1,class="checkbox",name="noread",label="Check for unreadable lines",value=true},
	{x=1,y=13,width=1,height=1,class="checkbox",name="redundant",label="Check for redundant tags",value=true},
	{x=1,y=14,width=1,height=1,class="checkbox",name="failita",label="Check for bad italics",value=true},
	{x=1,y=15,width=1,height=1,class="checkbox",name="mistyle",label="Check for missing styles",value=true},
	{x=1,y=16,width=1,height=1,class="checkbox",name="dlayer",label="Check dialogue layer",value=true},
	{x=1,y=17,width=1,height=1,class="checkbox",name="halfsec",label="Check for dialogue lines under 0.5s",value=true,hint="bur over 1 frame and over 8 characters"},
	
	{x=2,y=1,width=2,height=1,class="label",label="More useless statistics..."},
	{x=2,y=2,width=2,height=1,class="checkbox",name="italix",label="Count dialogue lines with italics tag",value=false},
	{x=2,y=3,width=2,height=1,class="checkbox",name="lbreax",label="Count dialogue lines with linebreaks",value=false},
	{x=2,y=4,width=2,height=1,class="checkbox",name="honorifix",label="Count honorifics (-san, -kun, -chan)",value=false},
	{x=2,y=5,width=2,height=1,class="checkbox",name="zero",label="Count lines with 0 time",value=false},
	{x=2,y=6,width=2,height=1,class="checkbox",name="empty",label="Count empty lines",value=false},
	{x=2,y=7,width=2,height=1,class="checkbox",name="oneframe",label="Count lines that last 1 frame",value=false},
	{x=2,y=8,width=2,height=1,class="checkbox",name="transline",label="Count lines with transforms",value=false},
	{x=2,y=9,width=2,height=1,class="checkbox",name="orgline",label="Count lines with \\org",value=false},
	{x=2,y=10,width=2,height=1,class="checkbox",name="longtext",label="Line with longest text",value=true},
	{x=2,y=11,width=2,height=1,class="checkbox",name="longline",label="Line with longest duration",value=true},
	{x=2,y=12,width=2,height=1,class="checkbox",name="highcps",label="Line with highest CPS",value=true},
	{x=2,y=13,width=2,height=1,class="checkbox",name="quot",label="Mark lines with in/out quotation marks",value=false},
	{x=2,y=14,width=2,height=1,class="checkbox",name="fontcheck",label="List used fonts",value=false},
	{x=2,y=15,width=2,height=1,class="checkbox",name="uselesstyle",label="List unused styles",value=false},
	{x=2,y=16,width=2,height=1,class="checkbox",name="sauro",label="Count lines with faggosaurosis",value=true},
	
	{x=1,y=18,width=2,height=1,class="label",label=""},
	{x=1,y=19,width=3,height=1,class="label",label="This is to help you spot mistakes. If you're using this INSTEAD of QC, you're dumb."},
	
	}
	buttons={">QC","Clear QC","Dial 5","Check all","Fuck this fansubbing business"}
	
	repeat
	    if pressed=="Check all" then
		for key,val in ipairs(dialog_config) do
		    if val.class=="checkbox" then
			if pressed=="Check all" then val.value=true end
		    end
		end
	    end
	pressed,res=aegisub.dialog.display(dialog_config,buttons,{ok='>QC',cancel='Fuck this fansubbing business'})
	until pressed~="Check all"
	
	if pressed==">QC" or pressed=="Clear QC" then qc(subs, sel) end
	if pressed=="Dial 5" then dial5(subs) end
	if pressed=="Fuck this fansubbing business" then aegisub.cancel() end
end

function kyuusii(subs, sel)
    konfig(subs, sel) 
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, kyuusii)