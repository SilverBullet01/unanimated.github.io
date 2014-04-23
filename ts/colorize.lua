﻿script_name="Colorize"
script_description="Does things with colours"
script_author="unanimated"
script_version="3.4"

--[[

 Bottom dropdown menu chooses mode:
	Colorize letter by letter:
 Alternates between 2-5 colours character by character, like 121212, 123123123, or 123412341234.
 Works for primary/border/shadow/secondary (only one of those).
 Nukes all comments and inline tags. Only first block of tags is kept.
	Shift:
 Shift can be used on an already colorized line to shift the colours by one letter.
 You have to set the right number of colours for it to work correctly!
 If shift base is "line", then it takes the colour for the first character from the last character.
 
   "Don't join with other tags" will keep {initial tags}{colour} separated (ie won't nuke the "}{"). 
 This helps some other scripts to keep the colour as part of the "text" without initial tags.
 
   "Continuous shift line by line" - If you select a bunch of the same colorized lines, this shifts the colours line by line.
 This kind of requires that no additional weird crap is done to the lines, otherwise malfunctioning can be expected.
 
   "Colorize by word"
 Colorizes by word instead of by letter.
 
   "Set colours across whole line"
 This is like a preparation for gradient-by-character. Select number of colours.
 For 3 colours, it will place one at the start, one in the middle, and one before the last character.
 Works for 2-10 colours and sets them evenly across the line. (Then you can run grad-by-char.)
 
	Match/switch/invert \c, \3c, 4c:
 This should be obvious from the names and should apply to all new colour tags in the line.
 
	Adjust RGB / Brightness
 Simple and lame way of increasing/decreasing brightness for one (RGB) or all (Brightness) colours.
 This works for lines with multiple same-type colour tags, including gradient by character.
 You can select from -10 to 10. One step is 1/16 of the spectrum.
 (The way this works: If colour is \c&H9D9337&, it's split to 9D 93 37, and the first number/letter of each is raised by one -> ADA347.)
 Check types of colours you want it to apply to.
 "Apply even to colours without tags in line" means it will be applied to the colour set in style.

--]]

re=require'aegisub.re'

function colors(subs,sel)
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Colorizing line %d/%d",x,#sel))
	line=subs[i]
	text=line.text
	
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col5=res.c5:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	    if res.kol=="primary" then k="\\c" text=text:gsub("\\1?c&H%x+&","") end
	    if res.kol=="border" then k="\\3c" text=text:gsub("\\3c&H%x+&","") end
	    if res.kol=="shadow" then k="\\4c" text=text:gsub("\\4c&H%x+&","") end
	    if res.kol=="secondary" then k="\\2c" text=text:gsub("\\2c&H%x+&","") end
	    
	    k1=k..col1
	    k2=k..col2
	    k3=k..col3
	    k4=k..col4
	    k5=k..col5

	    tags=""
	    if text:match("^{\\[^}]*}") then tags=text:match("^({\\[^}]*})") end
	    orig=text:gsub("^({\\[^}]*})","")
	    text=text:gsub("{[^}]*}","")
	    text=text:gsub("%s*$","")

	    if res.clrs=="2" then
	      if res.word then
		text=text.." * "
		text=re.sub(text,"([\\w[:punct:]]+) ([\\w[:punct:]]+) ","{\\"..k1.."}\\1 {\\"..k2.."}\\2 ")
	      else
		text=text:gsub("%s","  ") text=text.."*"
		text=re.sub(text,"([\\w[:punct:]\\s])([\\w[:punct:]\\s])","{\\"..k1.."}\\1{\\"..k2.."}\\2")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	      end
	    end
	    
	    if res.clrs=="3" then
	      if res.word then
		text=text.." * * "
		text=re.sub(text,"([\\w[:punct:]]+) ([\\w[:punct:]]+) ([\\w[:punct:]]+) ","{\\"..k1.."}\\1 {\\"..k2.."}\\2 {\\"..k3.."}\\3 ")
	      else
		text=text:gsub("%s","   ") text=text:gsub("\\N","\\N~") text=text.."**"
		text=re.sub(text,"([\\w[:punct:]\\s])([\\w[:punct:]\\s])([\\w[:punct:]\\s])","{\\"..k1.."}\\1{\\"..k2.."}\\2{\\"..k3.."}\\3")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~","")
	      end
	    end
	    
	    if res.clrs=="4" then
	      if res.word then
		text=text.." * * * "
		text=re.sub(text,"([\\w[:punct:]]+) ([\\w[:punct:]]+) ([\\w[:punct:]]+) ([\\w[:punct:]]+) ","{\\"..k1.."}\\1 {\\"..k2.."}\\2 {\\"..k3.."}\\3 {\\"..k4.."}\\4 ")
	      else
		text=text:gsub("%s","    ") text=text:gsub("\\N","\\N\\N") text=text.."***"
		text=re.sub(text,"([\\w[:punct:]\\s])([\\w[:punct:]\\s])([\\w[:punct:]\\s])([\\w[:punct:]\\s])","{\\"..k1.."}\\1{\\"..k2.."}\\2{\\"..k3.."}\\3{\\"..k4.."}\\4")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	      end
	    end
	    
	    if res.clrs=="5" then
	      if res.word then
		text=text.." * * * * "
		text=re.sub(text,"([\\w[:punct:]]+) ([\\w[:punct:]]+) ([\\w[:punct:]]+) ([\\w[:punct:]]+) ([\\w[:punct:]]+) ","{\\"..k1.."}\\1 {\\"..k2.."}\\2 {\\"..k3.."}\\3 {\\"..k4.."}\\4 {\\"..k5.."}\\5 ")
	      else
		text=text:gsub("%s","     ") text=text:gsub("\\N","\\N\\N~") text=text.."****"
		text=re.sub(text,"([\\w[:punct:]\\s])([\\w[:punct:]\\s])([\\w[:punct:]\\s])([\\w[:punct:]\\s])([\\w[:punct:]\\s])","{\\"..k1.."}\\1{\\"..k2.."}\\2{\\"..k3.."}\\3{\\"..k4.."}\\4{\\"..k5.."}\\5")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~","")
	      end
	    end

	    text=text:gsub("{\\[1234]?c&H%x+&}%*","")
	    text=text:gsub("[%s%*]+$","")
	    text=text:gsub(" $","")

	text=text:gsub("{\\[1234]?c&H%x+&}\\{\\[1234]?c&H%x+&}N","\\N")
	text=text:gsub("\\N\\N","\\N")
	text=tags..text
	if res.join==false then text=text:gsub("}{","") end
	if orig:match("{\\") then text=textmod(orig) end
	line.text=text
        subs[i]=line
    end
end

function textmod(orig)
    tk={}
    tg={}
	text=text:gsub("{\\\\k0}","")
	repeat text=text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	    until not text:match("{(\\[^}]-)}{(\\[^}]-)}")
	vis=text:gsub("{[^}]-}","")
	  for c in vis:gmatch(".") do
	    table.insert(tk,c)
	  end
	stags=text:match("^{(\\[^}]-)}")
	if stags==nil then stags="" end
	text=text:gsub("^{\\[^}]-}","") :gsub("{[^\\}]-}","")
	count=0
	for seq in text:gmatch("[^{]-{%*?\\[^}]-}") do
	    chars,as,tak=seq:match("([^{]-){(%*?)(\\[^}]-)}")
	    pos=chars:len()+count
	    tgl={p=pos,t=tak,a=as}
	    table.insert(tg,tgl)
	    count=pos
	end
	count=0
	for seq in orig:gmatch("[^{]-{%*?\\[^}]-}") do
	    chars,as,tak=seq:match("([^{]-){(%*?)(\\[^}]-)}")
	    pos=chars:len()+count
	    tgl={p=pos,t=tak,a=as}
	    table.insert(tg,tgl)
	    count=pos
	end
    newline=""
    for i=1,#tk do
	newline=newline..tk[i]
	newt=""
	for n, t in ipairs(tg) do
	    if t.p==i then newt=newt..t.t as=t.a end
	end
	if newt~="" then newline=newline.."{"..as..newt.."}" end
    end
    newtext="{"..stags.."}"..newline
    text=newtext
    return text
end

function gcolors(subs,sel)
cn=tonumber(res.gclrs)
fn=cn-1
-- factors table
fakt={0}
for f=1,fn do
    fk=f/fn
    table.insert(fakt,fk)
end
-- GUI
gc_config={{x=0,y=0,width=1,height=1,class="dropdown",name="gctype",items={"\\c","\\3c","\\4c","\\2c"},value="\\c"}}
for c=1,cn do
    cte={x=c,y=0,width=1,height=1,class="color",name="gc"..c}
    table.insert(gc_config,cte)
end
button={"This is a rather big button","Click this, and something might happen","What is this, I don't even","The do-not-cancel button","I accept the terms of this scam","Is this really the right button?","What do I do with all these colours?!","I sure hope nothing will break if I do this","Yeah, okay. Fine. I'm gonna click on this.","Is this button safe to click?","Anyone else feels like this is a bit random?","We interrupt your typesetting to bring you a button!","I assure you this script actually works (maybe)","No, but seriously, click me!"}
ex=math.random(1,#button)
if not res.rept then press,rez=aegisub.dialog.display(gc_config,{button[ex],"Cancel"},{close='Cancel'}) end
if press=="Cancel" then aegisub.cancel() end
kt=rez.gctype
-- colours table
kolors={}
for c=1,cn do
    gcol=rez["gc"..c]:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
    gcol=kt..gcol
    table.insert(kolors,gcol)
end

    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Colorizing line %d/%d",x,#sel))
	line=subs[i]
	text=line.text
	text=text:gsub("\\1c","\\c") :gsub(kt.."&H%x+&","")
	if not text:match("^{\\") then text=text:gsub("^","{\\clrs}") end
	
	clean=text:gsub("{[^}]-}","") :gsub("%s?\\[Nn]%s?"," ")
	text=text:gsub("%*","_ast_")
	
	for n=cn,1,-1 do
		lngth=math.floor(clean:len()*fakt[n])
		text="*"..text
		text=text:gsub("%*({\\[^}]-})","%1*")
		tags=kolors[n]
		m=0
		if lngth>0 then
		  repeat text=text:gsub("%*({[^}]-})","%1*") :gsub("%*(.)","%1*") :gsub("%*(%s?\\[Nn]%s?)","%1*") m=m+1
		  until m==lngth
		end
		if n==cn then text=text:gsub("([^}])%*$","*%1") :gsub("([^}])%*({[^\\}]-})$","*%1%2") end
		text=text:gsub("%*","{"..tags.."}") :gsub("({"..tags.."})({[^}]-})","%2%1") 
		:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}") :gsub("("..kt.."&H%x+&)"..kt.."&H%x+&","%1")
	end
	
	text=text:gsub("\\clrs","") :gsub("_ast_","*") :gsub("{}","")
	line.text=text
        subs[i]=line
    end
end

function shift(subs,sel)
	klrs=tonumber(res.clrs)	-- how many colours we're dealing with
	count=1				-- start line counter
	if res.shit=="line" then sline=true else sline=false end
    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Colorizing line %d/%d",x,#sel))
	local line=subs[i]
	local text=line.text

	    -- check if line looks colorized
	    if not text:match("{(\\[1234]?c)&H%x+&}[%w%p]") then aegisub.dialog.display({{class="label",
		label="Line "..x.." does not \nappear to be colorized",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()
	    end

	    -- determine which colour has been used to colorize - 1c, 2c, 3c, 4c
	    if sline then 
		matches=re.find(text,"\\{\\*?\\\\[1234]?c&H[A-Fa-f0-9]+&\\}[^\\{]*$")
		cms=matches[1].str
		ctype,shc=cms:match("{%*?(\\[1234]?c)(&H%x+&)}[^{]*$")
		first="{"..ctype..shc.."}"
		
		else
		matches=re.find(text,"\\{\\\\[1234]?c&H[A-Fa-f0-9]+&\\}[\\w[:punct:]]")
		cms=matches[1].str
		ctype=cms:match("\\[1234]?c")

		-- get colours 2, 3, 4, 5, and create sequences for shifting
		matches=re.match(text,"([\\w[:punct:]]\\s?)(\\{\\"..ctype.."&H[A-Fa-f0-9]+&\\})([\\w[:punct:]]\\s?)(\\{\\"..ctype.."&H[A-Fa-f0-9]+&\\})([\\w[:punct:]]\\s?)(\\{\\"..ctype.."&H[A-Fa-f0-9]+&\\})([\\w[:punct:]]\\s?)(\\{\\"..ctype.."&H[A-Fa-f0-9]+&\\})")
		if matches==nil then 
		  matches=re.match(text,"([\\w[:punct:]]\\s?)(\\{\\"..ctype.."&H[A-Fa-f0-9]+&\\})([\\w[:punct:]]\\s?)(\\{\\"..ctype.."&H[A-Fa-f0-9]+&\\})")
		  c2=matches[3].str	c3=matches[5].str
		  else
		  c2=matches[3].str	c3=matches[5].str	c4=matches[7].str	c5=matches[9].str
		end
		
		if klrs==2 then first=c2 end
		if klrs==3 then first=c3 second=c2 end
		if klrs==4 then first=c4 second=c3 third=c2 end
		if klrs==5 then first=c5 second=c4 third=c3 fourth=c2 end
	    end

	    -- don't run for 1st lines in sequences
	    if count>1 or not res.cont then

		-- separate first colour tag from other tags, save initial tags
		tags=""
		if text:match("^{[^}]*"..ctype.."&") then text=text:gsub("^({[^}]*)("..ctype.."&H%x+&)([^}]*})","%1%3{%2}") end
		if not text:match("^{\\[1234]?c&H%x+&}") then tags=text:match("^({\\[^}]*})") text=text:gsub("^{\\[^}]*}","") end

		-- shifting colours happens here
		switch=1
		repeat 
		text=re.sub(text, "(\\{\\*?\\\\[1234]?c&H[A-Fa-f0-9]+&\\})([\\w[:punct:]])", "\\2\\1")
		text=re.sub(text, "(\\{\\*?\\\\[1234]?c&H[A-Fa-f0-9]+&\\})(\\s)", "\\2\\1")
		text=re.sub(text, "(\\{\\*?\\\\[1234]?c&H[A-Fa-f0-9]+&\\})(\\\\N)", "\\2\\1")
		text=re.sub(text, "(\\{\\*?\\\\[1234]?c&H[A-Fa-f0-9]+&\\})$", "")
		text=first..text
		switch=switch+1
		if not sline then
		  if switch==2 then first=second end
		  if switch==3 then first=third end
		  if switch==4 then first=fourth end
		else
		  matches=re.find(text,"\\{\\\\[1234]?c&H[A-Fa-f0-9]+&\\}[^\\{]*$")
		  ctype,shc=cms:match("{%*?(\\[1234]?c)(&H%x+&)}[^{]*$")
		  first="{"..ctype..shc.."}"
		end
		  for cl1,cl2,cl3 in text:gmatch("({\\[1234]?c&H%x+&})([%w%p%s])({\\[1234]?c&H%x+&})") do
		    if cl1==cl3 then 
		    text=text:gsub(cl1..cl2..cl3,cl1..cl2)
		    end
		  end
		until switch>=count

		if tags~=nil then text=tags..text end
		if res.join==false then text=text:gsub("}{","") end
	    end

	-- line counter
	if res.cont then count=count+1 end
	if not sline and count>klrs then count=1 end
	line.text=text
        subs[i]=line
    end
end

function matchcolors(subs,sel)
match_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="copy primary\nto outline"},
	{x=2,y=0,width=1,height=1,class="label",label="copy outline\nto primary"},
	{x=4,y=0,width=1,height=1,class="label",label="copy primary\nto shadow"},
	{x=6,y=0,width=1,height=1,class="label",label="copy outline\nto shadow"},
	{x=8,y=0,width=1,height=1,class="label",label="switch primary\nand outline"},
	{x=10,y=0,width=1,height=1,class="label",label="invert all \ncolours"},
	}
if pressed=="Match Colours" then
	press,rez=aegisub.dialog.display(match_config,{"c --> 3c","3c --> c","c --> 4c","3c --> 4c","c <--> 3c","Invert","Cancel"},{close='Cancel'})
end

    for x, i in ipairs(sel) do
        aegisub.progress.title(string.format("Colorizing line %d/%d",x,#sel))
	local line=subs[i]
	local text=line.text
	if defaref~=nil and line.style=="Default" then styleref=defaref
	elseif lastref~=nil and laststyle==line.style then styleref=lastref
	else styleref=stylechk(line.style) end
	lastref=styleref	laststyle=line.style
	
		stylecol={}
		
		primary=styleref.color1:gsub("H%x%x","H")	sc1=primary	table.insert(stylecol,sc1)
		pri=text:match("^{[^}]-\\c(&H%x+&)")		if pri~=nil then primary=pri end
		
		secondary=styleref.color2:gsub("H%x%x","H")	sc2=secondary	table.insert(stylecol,sc2)
		sec=text:match("^{[^}]-\\3c(&H%x+&)")		if sec~=nil then secondary=sec end
		
		outline=styleref.color3:gsub("H%x%x","H")	sc3=outline	table.insert(stylecol,sc3)
		out=text:match("^{[^}]-\\3c(&H%x+&)")		if out~=nil then outline=out end
		
		shadow=styleref.color4:gsub("H%x%x","H")	sc4=shadow	table.insert(stylecol,sc4)
		sha=text:match("^{[^}]-\\c(&H%x+&)")		if sha~=nil then shadow=sha end
		
	    if res.kol=="primary" then k="\\c" end
	    if res.kol=="border" then k="\\3c" end
	    if res.kol=="shadow" then k="\\4c" end
	    if res.kol=="secondary" then k="\\2c" end
	    text=text:gsub("\\1c","\\c")
	    if not text:match("^{\\") then text=text:gsub("^","{\\}") end

	-- 1-->3   match outline to primary
	if pressed=="Match Colours" and press=="c --> 3c" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\3c") and not ctags:match("\\1?c") then ctags2=ctags:gsub("\\3c&H%w+&","\\3c"..primary) end
		if ctags:match("\\1?c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\1?c(&H%w+&)") ctags2=ctags:gsub("\\3c&H%w+&","\\3c"..tempc) end
		if ctags:match("\\1?c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("\\1?c(&H%w+&)","\\c%1\\3c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\3c") and not ctags:match("\\1?c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\3c"..primary.."}") end
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end

	-- 3-->1   match primary to outline
	if pressed=="Match Colours" and press=="3c --> c" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\1?c") and not ctags:match("\\3c") then ctags2=ctags:gsub("\\1?c&H%w+&","\\c"..outline) end
		if ctags:match("\\1?c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\3c(&H%w+&)") ctags2=ctags:gsub("\\1?c&H%w+&","\\c"..tempc) end
		if ctags:match("\\3c") and not ctags:match("\\1?c") then
		  ctags2=ctags:gsub("\\3c(&H%w+&)","\\c%1\\3c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\1?c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\c"..outline.."}") end
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end
	
	-- 3-->4   match shadow to outline
	if pressed=="Match Colours" and press=="3c --> 4c" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\4c") and not ctags:match("\\3c") then ctags2=ctags:gsub("\\4c&H%w+&","\\4c"..outline) end
		if ctags:match("\\4c") and ctags:match("\\3c") then 
		  tempc=ctags:match("\\3c(&H%w+&)") ctags2=ctags:gsub("\\4c&H%w+&","\\4c"..tempc) end
		if ctags:match("\\3c") and not ctags:match("\\4c") then
		  ctags2=ctags:gsub("\\3c(&H%w+&)","\\3c%1\\4c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\4c") and not ctags:match("\\3c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\4c"..outline.."}") end
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end
	
	-- 3-->4   match shadow to primary
	if pressed=="Match Colours" and press=="c --> 4c" then
	    for ctags in text:gmatch("({\\[^}]-})") do
		ctags2=nil
		if ctags:match("\\4c") and not ctags:match("\\c") then ctags2=ctags:gsub("\\4c&H%w+&","\\4c"..primary) end
		if ctags:match("\\4c") and ctags:match("\\c") then 
		  tempc=ctags:match("\\c(&H%w+&)") ctags2=ctags:gsub("\\4c&H%w+&","\\4c"..tempc) end
		if ctags:match("\\c") and not ctags:match("\\4c") then
		  ctags2=ctags:gsub("\\c(&H%w+&)","\\c%1\\4c%1") end
		if ctags==text:match("^({\\[^}]-})") and not ctags:match("\\4c") and not ctags:match("\\c") then
		  ctags2=ctags:gsub("^({\\[^}]-)}","%1\\4c"..primary.."}") end
		if ctags2~=nil then ctags=esc(ctags) text=text:gsub(ctags,ctags2) end
	    end
	end

	-- 1<-->3   switch primary and border
	if pressed=="Match Colours" and press=="c <--> 3c" then
	    if text:match("^{\\") then
		tags=text:match("^({\\[^}]-})")
		if tags:match("\\1?c") then tags=tags:gsub("\\1?c","\\tempc")
		else tags=tags:gsub("({\\[^}]-)}","%1\\tempc"..primary.."}") end
		if tags:match("\\3c") then tags=tags:gsub("\\3c","\\c")
		else tags=tags:gsub("({\\[^}]-)}","%1\\c"..outline.."}") end
		tags=tags:gsub("\\tempc","\\3c")
		after=text:match("^{\\[^}]-}(.*)")
		after=after:gsub("\\1?c","\\tempc")
		after=after:gsub("\\3c","\\c")
		after=after:gsub("\\tempc","\\3c")
		text=tags..after
	    else
		tags="{\\c"..outline.."\\3c"..primary.."}"
		after=text
		after=after:gsub("\\1?c","\\tempc")
		after=after:gsub("\\3c","\\c")
		after=after:gsub("\\tempc","\\3c")
		text=tags..after
	    end
	end

	-- Invert All Colours  
	if pressed=="Match Colours" and press=="Invert" then
	    if not text:match("^{\\") then text="{\\what}"..text end
		tags=text:match("^({\\[^}]-})")
		for n=1,4 do
		    ctg="\\"..n.."c"
		    ctg=ctg:gsub("1","")
		    if not tags:match(ctg) and n~=2 then text=text:gsub("^({\\[^}]-)}","%1"..ctg..stylecol[n].."}") end
		end
		for color in text:gmatch("\\[1234]?c&H(%x%x%x%x%x%x)&") do
		    icolor=""
		    for kol in color:gmatch("(%x%x)") do
			dkol=tonumber(kol,16)
			idkol=255-dkol
			ikol=to_hex(idkol)
			icolor=icolor..ikol
		    end
		    text=text:gsub("&H"..color.."&","&H"..icolor.."&")
		end
	    text=text:gsub("\\what","")
	end

	-- RGB Colour / BRIGHTNESS
	if pressed=="RGB" or pressed=="Brightness" then
	    lvlr=res.R lvlg=res.G lvlb=res.B
	    brite=res.bright
	    corols={}
	    if res.k1 then table.insert(corols,"1") end
	    if res.k2 then table.insert(corols,"2") end
	    if res.k3 then table.insert(corols,"3") end
	    if res.k4 then table.insert(corols,"4") end
	    tagz=text:match("^({\\[^}]-})")
	    
	    for i=1,#corols do
		n=tonumber(corols[i])
		local kl="\\"..n.."c"
		kl=kl:gsub("\\1c","\\c")
		--aegisub.log("\n kl: "..kl)
		
		if res.mktag and not tagz:match(kl) then
		    text=text:gsub("^({\\[^}]-)}","%1"..kl..stylecol[n].."}")
		end 
	      
		if pressed=="RGB" then
		  for kol1,kol2,kol3 in text:gmatch(kl.."&H(%x%x)(%x%x)(%x%x)&") do
		    kol1n=brightness(kol1,lvlb)
		    kol2n=brightness(kol2,lvlg)
		    kol3n=brightness(kol3,lvlr)
		  text=text:gsub(kol1..kol2..kol3,kol1n..kol2n..kol3n)
		  end
		end
		
		if pressed=="Brightness" then
		  for kol1,kol2,kol3 in text:gmatch(kl.."&H(%x%x)(%x%x)(%x%x)&") do
		    kol1n=brightness(kol1,brite)
		    kol2n=brightness(kol2,brite)
		    kol3n=brightness(kol3,brite)
		  text=text:gsub(kol1..kol2..kol3,kol1n..kol2n..kol3n)
		  end
		end
	    end
	end

	text=text:gsub("\\\\","\\") :gsub("\\}","}") :gsub("{}","")
	line.text=text
        subs[i]=line
    end
end

function brightness(klr,lvl)
    ka,kb=klr:match("(%x)(%x)")
    ka=tonumber(ka,16)
    ka=ka+lvl
    ka=tohex(ka)
    klr2=ka..kb
return klr2
end

function to_hex(num)
    n1=math.floor(num/16)
    n2=num%16
    num=tohex(n1)..tohex(n2)
return num
end

function tohex(num)
    if num<1 then num="0"
    elseif num>14 then num="F"
    elseif num==10 then num="A"
    elseif num==11 then num="B"
    elseif num==12 then num="C"
    elseif num==13 then num="D"
    elseif num==14 then num="E" end
return num
end

function styleget(subs)
    styles={}
    for i=1, #subs do
        if subs[i].class=="style" then
	    table.insert(styles,subs[i])
	end
	if subs[i].class=="dialogue" then break end
    end
end

function stylechk(stylename)
    for i=1,#styles do
	if stylename==styles[i].name then
	    styleref=styles[i]
	    if styles[i].name=="Default" then defaref=styles[i] end
	    break
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

function repetition()
	if res.rept then
	res.clrs=lastclrs
	res.shit=lastshit
	res.kol=lastkol
	res.c1=lastc1
	res.c2=lastc2
	res.c3=lastc3
	res.c4=lastc4
	res.c5=lastc5
	res.join=lastjoin
	res.cont=lastcont
	res.word=lastword
	res.R=lastR
	res.G=lastG
	res.B=lastB
	res.bright=lastbright
	res.k1=lastk1
	res.k2=lastk2
	res.k3=lastk3
	res.k4=lastk4
	res.mktag=lastmktag
	res.gclrs=lastgclrs
	res.gcl=lastgcl
	end
end

function colorize(subs,sel)
	dialog_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="Colours"},
	{x=1,y=0,width=1,height=1,class="dropdown",name="clrs",items={"2","3","4","5"},value="2"},
	
	{x=0,y=1,width=1,height=1,class="label",label="Shift base:"},
	{x=1,y=1,width=1,height=1,class="dropdown",name="shit",items={"# of colours","line"},value="# of colours"},
	
	{x=0,y=2,width=1,height=1,class="label",label="Apply to:  "},
	{x=1,y=2,width=1,height=1,class="dropdown",name="kol",items={"primary","border","shadow","secondary"},value="primary"},
	    
	{x=3,y=0,width=1,height=1,class="label",label="  1 "},
	{x=3,y=1,width=1,height=1,class="label",label="  2 "},
	{x=3,y=2,width=1,height=1,class="label",label="  3 "},
	{x=3,y=3,width=1,height=1,class="label",label="  4 "},
	{x=3,y=4,width=1,height=1,class="label",label="  5 "},
	
	{x=4,y=0,width=1,height=1,class="color",name="c1" },
	{x=4,y=1,width=1,height=1,class="color",name="c2" },
	{x=4,y=2,width=1,height=1,class="color",name="c3" },
	{x=4,y=3,width=1,height=1,class="color",name="c4" },
	{x=4,y=4,width=1,height=1,class="color",name="c5" },
	
	{x=0,y=3,width=2,height=1,class="checkbox",name="join",label="Don't join with other tags",value=false },
	{x=0,y=4,width=3,height=1,class="checkbox",name="cont",label="Continuous shift line by line",value=false },
	{x=0,y=5,width=3,height=1,class="checkbox",name="word",label="Colorize by word",value=false },
	{x=0,y=6,width=4,height=1,class="checkbox",name="gcl",label="Set colours across whole line:",value=false },
	{x=4,y=6,width=1,height=1,class="dropdown",name="gclrs",items={"2","3","4","5","6","7","8","9","10"},value="3"},
	{x=0,y=7,width=5,height=1,class="checkbox",name="rept",label="repeat with last settings (any function)",value=false },
		
	{x=5,y=0,width=1,height=1,class="label",label=" "},
		
	{x=6,y=0,width=1,height=1,class="label",label="Red: "},
	{x=7,y=0,width=2,height=1,class="intedit",name="R",value=0,min=-10,max=10},
	{x=6,y=1,width=1,height=1,class="label",label="Green: "},
	{x=7,y=1,width=2,height=1,class="intedit",name="G",value=0,min=-10,max=10},
	{x=6,y=2,width=1,height=1,class="label",label="Blue: "},
	{x=7,y=2,width=2,height=1,class="intedit",name="B",value=0,min=-10,max=10},
	{x=6,y=4,width=1,height=1,class="label",label="Brightness:"},
	{x=7,y=4,width=2,height=1,class="intedit",name="bright",value=0,min=-10,max=10},
	{x=6,y=3,width=5,height=1,class="label",label="From -10 to 10. 1 step is 1/16 of the spectrum."},
	{x=6,y=5,width=5,height=1,class="label",label="1 step for brightness equals 1 step for R+G+B."},

	{x=6,y=6,width=1,height=1,class="checkbox",name="k1",label="\\c       ", value=true  },
	{x=7,y=6,width=1,height=1,class="checkbox",name="k3",label="\\3c      ",value=false },
	{x=8,y=6,width=1,height=1,class="checkbox",name="k4",label="\\4c      ",value=false },
	{x=9,y=6,width=1,height=1,class="checkbox",name="k2",label="\\2c",value=false },
	{x=6,y=7,width=5,height=1,class="checkbox",name="mktag",label="apply even to colours without tags in line", value=false },
	
	{x=9,y=0,width=1,height=1,class="label",label="[v "..script_version.."]"},
	
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,{"Colorize","Shift","Match Colours","RGB","Brightness","Cancel"},{ok='Colorize',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Colorize" then repetition() 
	    if res.gcl then gcolors(subs,sel) else colors(subs,sel) end
	end
	if pressed=="Shift" then repetition() shift(subs,sel) end
	if pressed=="Match Colours" or pressed=="RGB" or pressed=="Brightness" then repetition() styleget(subs) matchcolors(subs,sel) end
	
	lastclrs=res.clrs
	lastshit=res.shit
	lastkol=res.kol
	lastc1=res.c1
	lastc2=res.c2
	lastc3=res.c3
	lastc4=res.c4
	lastc5=res.c5
	lastjoin=res.join
	lastcont=res.cont
	lastword=res.word
	lastR=res.R
	lastG=res.G
	lastB=res.B
	lastbright=res.bright
	lastk1=res.k1
	lastk2=res.k2
	lastk3=res.k3
	lastk4=res.k4
	lastmktag=res.mktag
	lastgcl=res.gcl
	lastgclrs=res.gclrs
    
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, colorize)