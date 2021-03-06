-- This turns your \fad tag into \t\alpha, letting you add accel for the fade in and fade out.
-- Supports present alpha tags. Supports multiple alpha tags in line (at least it should).
-- If there already is an alpha transform, expect things to break.
-- Added option to fade to/from black/white. Should support inline \c and \3c tags.
-- Does NOT support \2c, \4c, \1a, \2a, \3a, \4a.

script_name = "Turn fade into transform"
script_description = "Turn fade into alpha transform"
script_author = "unanimated"
script_version = "1.5"

include("karaskel.lua")

function fadalpha(subs, sel)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    karaskel.preproc_line(sub,meta,styles,line)
		if text:match("\\fad%(") then
		fadin,fadout = text:match("\\fad%((%d+)%,(%d+)")
		primary=line.styleref.color1		primary=primary:gsub("H%x%x","H")
		pri=text:match("^{\\[^}]-\\c(&H%x+&)")		if pri~=nil then primary=pri end
		outline=line.styleref.color3		outline=outline:gsub("H%x%x","H")
		out=text:match("^{\\[^}]-\\3c(&H%x+&)")		if out~=nil then outline=out end
		border=line.styleref.outline
		bord=text:match("\\bord([%d%.]+)")	if bord~=nil then border=bord end

		black1="\\c&H000000&"	black3="\\3c&H000000&"		black=black1..black3
		white1="\\c&HFFFFFF&"	white3="\\3c&HFFFFFF&"		white=white1..white3
		a00="\\alpha&H00&"	aff="\\alpha&HFF&"
		if res.kolora=="Fade from Black" then 
			kolora1=black1 kolora3=black3 kolora=black else kolora1=white1 kolora3=white3 kolora=white end
		if res.kolorb=="Fade to Black" then 
			kolorb1=black1 kolorb3=black3 kolorb=black else kolorb1=white1 kolorb3=white3 kolorb=white end

	-- with alpha in line
		if text:match("\\alpha&H%x%x&") then

		    if fadin~="0" then
		-- fade from colour
			    if res.crl then
			text=text:gsub("^({\\[^}]-)\\1?c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)\\3c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)}",
			"%1"..kolora.."\\t(0," .. fadin .."," .. res.inn .. ",\\c"..primary.."\\3c"..outline..")}")
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
					col1="" col3=""
					if t:match("\\1?c") then col1=t:match("(\\1?c&%w+&)") end
					if t:match("\\3c") then col3=t:match("(\\3c&%w+&)") end
			t2=t:gsub("\\1?c&%w+&",kolora1)	
			t2=t2:gsub("\\3c&%w+&",kolora3)	
			t2=t2:gsub("({[^}]-)}","%1\\t(0," ..fadin.."," ..res.inn.. ","..col1..col3..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade from alpha
			    else
			if text:match("^{\\[^}]-\\alpha&H%x%x&") then
			text=text:gsub("^{(\\[^}]-)(\\alpha&H%x%x&)([^}]-)}","{%1%3\\alpha&HFF&\\t(0," ..fadin.."," ..res.inn.. ",%2)}")
			else 
			text=text:gsub("^{(\\[^}]-)}","{%1"..aff.."\\t(0," ..fadin.."," ..res.inn.. ","..a00..")}")
			end
		-- inline alpha tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\alpha") then
				arfa=t:match("(\\alpha&%w+&)")
			t2=t:gsub("\\alpha&%w+&",aff)	
			t2=t2:gsub("({[^}]-)}","%1\\t(0," ..fadin.."," ..res.inn.. ","..arfa..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
			    end
		    end

		    if fadout~="0" then
		-- fade to colour
			    if res.clr then
			text=text:gsub("^({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..res.ut.. ","..kolorb..")}")
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
			t2=t:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..res.ut.. ","..kolorb..")}")
			if not t:match("\\1?c") then t2=t2:gsub("\\c&%w+&","") end
			if not t:match("\\3c") then t2=t2:gsub("\\3c&%w+&","") end
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade to alpha
			    else
			text=text:gsub("^({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..res.ut.. ","..aff..")}")
		-- inline alpha tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\alpha") then
				
			t2=t:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..res.ut.. ","..aff..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
			    end
		    end
	-- without alpha
		else

		    if fadin~="0" then
		-- fade from colour
			    if res.crl then
			text=text:gsub("^({\\[^}]-)\\1?c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)\\3c&H%x+&","%1")
			text=text:gsub("^({\\[^}]-)}",
			"%1"..kolora.."\\t(0," .. fadin .."," .. res.inn .. ",\\c"..primary.."\\3c"..outline..")}")
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
				col1="" col3=""
				if t:match("\\1?c") then col1=t:match("(\\1?c&%w+&)") end
				if t:match("\\3c") then col3=t:match("(\\3c&%w+&)") end
			t2=t:gsub("\\1?c&%w+&",kolora1)	
			t2=t2:gsub("\\3c&%w+&",kolora3)	
			t2=t2:gsub("({[^}]-)}","%1\\t(0," ..fadin.."," ..res.inn.. ","..col1..col3..")}")
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade from alpha
			    else
			text=text:gsub("^({\\[^}]-)}","%1"..aff.."\\t(0," .. fadin .."," .. res.inn .. ","..a00..")}")
			    end
		    end

		    if fadout~="0" then
		-- fade to colour
			    if res.clr then
			text=text:gsub("^({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..res.ut.. ","..kolorb..")}") 
		-- inline colour tags
			for t in text:gmatch("({\\[^}]-})") do
				if t~=text:match("^{\\[^}]-}") and t:match("\\[13]?c") then
			t2=t:gsub("({\\[^}]-)}","%1\\t(" ..line.duration-fadout..",0," ..res.ut.. ","..kolorb..")}")
			if not t:match("\\1?c") then t2=t2:gsub("\\c&%w+&","") end
			if not t:match("\\3c") then t2=t2:gsub("\\3c&%w+&","") end
			t=esc(t)
			text=text:gsub(t,t2)
				end
			end
		-- fade to alpha
			    else
			text=text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout ..",0," .. res.ut .. ","..aff..")}")
			    end
		    end
		end
		if border=="0" then text=text:gsub("\\3c&H%d+&","") end
		if not text:match("\\fad%(0,0%)") then text=text:gsub("\\fad%(%d+%,%d+%)","") end	-- nuke the fade
		end
	    line.text=text
	    subs[i] = line
	end
end

function esc(str)
	str=str:gsub("%%","%%%%")
	str=str:gsub("%(","%%%(")
	str=str:gsub("%)","%%%)")
	str=str:gsub("%[","%%%[")
	str=str:gsub("%]","%%%]")
	str=str:gsub("%.","%%%.")
	str=str:gsub("%*","%%%*")
	str=str:gsub("%-","%%%-")
	str=str:gsub("%+","%%%+")
	str=str:gsub("%?","%%%?")
	return str
end

function konfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=1,width=1,height=1,class="label",label="Fade in accel:",},
	    {x=0,y=2,width=1,height=1,class="label",label="Fade out accel:",},
	    {x=1,y=1,width=1,height=1,class="floatedit",name="inn",value="1"},
	    {x=1,y=2,width=1,height=1,class="floatedit",name="ut",value="1"},
	    {x=0,y=0,width=2,height=1,class="label",label="This will turn \\fad into \\t\\alpha with accel",},
	    {x=0,y=3,width=2,height=1,class="label",label="accel <1 starts fast, ends slow",},
	    {x=0,y=4,width=2,height=1,class="label",label="accel >1 starts slow, ends fast",},
	    {x=0,y=5,width=2,height=1,class="checkbox",name="clr",label="fade to colour",value=false},
	    {x=0,y=6,width=2,height=1,class="dropdown",name="kolorb",items={"Fade to Black","Fade to White"},value="Fade to Black"},
	    {x=0,y=7,width=2,height=1,class="checkbox",name="crl",label="fade from colour",value=false},
	    {x=0,y=8,width=2,height=1,class="dropdown",name="kolora",items={"Fade from Black","Fade from White"},value="Fade from White"},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Transform","Cancel"})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Transform" then fadalpha(subs, sel) end
end

function fade2alpha(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, fade2alpha)