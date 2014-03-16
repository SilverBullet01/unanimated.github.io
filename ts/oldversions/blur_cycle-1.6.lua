-- Adds blur 0.6, then cycles through 0.8, 1, 1.2, 1.5, 2, 3, 4, 5, 0.4, 0.5, back to 0.6. Feel free to modify the sequence below.

script_name="Blur Cycle"
script_description="Adds blur"
script_author="unanimated"
script_version="1.6"

sequence={"0.6","0.8","1","1.2","1.5","2","3","4","5","8","0.4","0.5"}	-- you can modify this

function blur(subs,sel)
    for z, i in ipairs(sel) do
	line=subs[i]
	text=line.text
	    tf=""
	    if text:match("^{\\[^}]-}") then
	    tags,after=text:match("^({\\[^}]-})(.*)")
		if tags:match("\\t") then 
		    for t in tags:gmatch("(\\t%([^%(%)]-%))") do tf=tf..t end
		    for t in tags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","") do tf=tf..t end
		    tags=tags:gsub("\\t%([^%(%)]+%)","")
		    tags=tags:gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","")
		    text=tags..after
		end
	    end

	    bl=text:match("^{[^}]-\\blur([%d%.]+)")
	    if bl~=nil then
		for b=1,#sequence do
		    if bl==sequence[b] then bl2=sequence[b+1] end
		end
		if bl2==nil then bl2="0.6" end
		text=text:gsub("^({[^}]-\\blur)[%d%.]+","%1"..bl2)
	    else
		text="{\\blur0.6}" .. text
		text=text:gsub("{\\blur0%.6}{\\","{\\blur0.6\\")
	    end

	text=text:gsub("^({\\[^}]-)}","%1"..tf.."}")
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, blur)