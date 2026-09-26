--18

local TweenService=game:GetService("TweenService")local UserInputService=game:GetService("UserInputService")local GuiService=game:GetService("GuiService")local RunService=game:GetService("RunService")local HttpService=game:GetService("HttpService")local Players=game:GetService("Players")local LocalPlayer=Players.LocalPlayer
local Library={}Library.Flags={}Library.Windows={}local applyLocked
local WINDOW_REGISTRY_KEY="__JinHub_UI_WindowRegistry"
local function getPersistentWindowRegistry()local environment=_G
pcall(function()if type(getgenv)=="function" then
environment=getgenv()end
end)if type(environment)~="table" then
return nil
end
local registry=environment[WINDOW_REGISTRY_KEY]if type(registry)~="table" then
registry={}environment[WINDOW_REGISTRY_KEY]=registry
end
return registry
end
local function normalize(source,map)local opts={}if type(source)=="string" then
opts.Name=source
elseif type(source)=="table" then
for key,value in pairs(source)do
opts[key]=value
end
end
for from,to in pairs(map or{})do
if opts[to]==nil and opts[from]~=nil then
opts[to]=opts[from]end
end
if opts.Range then
opts.Min=opts.Min or opts.Range[1]opts.Max=opts.Max or opts.Range[2]end
return opts
end
local function finishElement(tab,opts,element,frame,kind)element._type=kind
element._frame=frame
element._window=tab and tab.Window
element._listeners=element._listeners or{}local window=tab and tab.Window
if window then
window._elements=window._elements or{}window._elements[element]=true
end
local lockable=kind=="Toggle" or kind=="Dropdown" or kind=="Input"
or kind=="Slider" or kind=="Button"
if opts.Locked==true and lockable and frame and applyLocked then
applyLocked(frame,window)end
local sectionOwner=tab and tab._sectionOwner
if sectionOwner and sectionOwner._children then
table.insert(sectionOwner._children,element)end
if opts.Flag then
Library.Flags[opts.Flag]=element
if window then
local callback=opts.Callback
opts.Callback=function(...)if type(callback)=="function" then
callback(...)end
window:_autoSave()end
end
end
function element:Destroy()if element._destroyed then
return
end
element._destroyed=true
if element._children then
local children=table.clone(element._children)for index=#children,1,-1 do
local child=children[index]if child.Destroy then
child:Destroy()end
end
element._children={}end
for _,disconnect in ipairs(element._listeners)do
pcall(disconnect)end
element._listeners={}if window and window._elements then
window._elements[element]=nil
end
if opts.Flag and Library.Flags[opts.Flag]==element then
Library.Flags[opts.Flag]=nil
end
if window then
window._controlsDirty=true
end
if frame then
frame:Destroy()end
end
return element
end
Library.Theme={Background=Color3.fromRGB(20,16,20),Surface=Color3.fromRGB(24,19,24),Surface2=Color3.fromRGB(28,22,28),Surface3=Color3.fromRGB(42,36,43),Stroke=Color3.fromRGB(40,32,41),StrokeHover=Color3.fromRGB(88,70,90),Accent=Color3.fromRGB(235,199,246),AccentDark=Color3.fromRGB(24,18,26),Text=Color3.fromRGB(233,229,234),Muted=Color3.fromRGB(125,115,126),Warning=Color3.fromRGB(240,176,108),Success=Color3.fromRGB(150,220,170),Error=Color3.fromRGB(240,120,120),}Library.Assets={Shadow="rbxassetid://6014261993",Glow="rbxassetid://8992230677",Logo="rbxassetid://103859712365480",}local LUCIDE_URL="https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
local lucideSet=nil
local function loadLucide()if lucideSet~=nil then
return lucideSet
end
local ok,result=pcall(function()local source=game:HttpGet(LUCIDE_URL)return loadstring(source)()end)if ok and type(result)=="table" then
lucideSet=result
else
lucideSet=false
end
return lucideSet
end
local FONT_PRESETS={ValleySans={Regular="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Regular.ttf",Medium="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Medium.ttf",SemiBold="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-SemiBold.ttf",},}local FONT_WEIGHTS={Regular={400,Enum.FontWeight.Regular},Medium={500,Enum.FontWeight.Medium},SemiBold={600,Enum.FontWeight.SemiBold},Bold={700,Enum.FontWeight.Bold},}function Library:LoadFont(opts)opts=normalize(opts,{})if type(writefile)~="function" or type(isfile)~="function" or typeof(getcustomasset)~="function" then
return false
end
local name=opts.Name or "CustomFont"
local weights=opts.Weights or FONT_PRESETS[name]if type(weights)~="table" then
return false
end
local folder=opts.Folder or "JinHubFonts"
local legacyFolder=opts.Folder==nil and "AirFlowFonts" or nil
pcall(function()if type(isfolder)=="function" and type(makefolder)=="function" and not isfolder(folder)then
makefolder(folder)end
end)local faces={}for weightName,url in pairs(weights)do
local info=FONT_WEIGHTS[weightName]if info then
local path=folder.."/"..name.."-"..weightName..".ttf"
local ok=true
local assetPath=path
local legacyPath=legacyFolder and(legacyFolder.."/"..name.."-"..weightName..".ttf")local hasCurrentPath=isfile(path)if not hasCurrentPath and legacyPath and isfile(legacyPath)then
assetPath=legacyPath
elseif not hasCurrentPath then
ok=pcall(function()writefile(path,game:HttpGet(url))end)end
if ok then
table.insert(faces,{name=weightName,weight=info[1],style="normal",assetId=getcustomasset(assetPath)})end
end
end
if #faces==0 then
return false
end
local familyPath=folder.."/"..name..".json"
local okWrite=pcall(function()writefile(familyPath,HttpService:JSONEncode({name=name,faces=faces}))end)if not okWrite then
return false
end
local family=getcustomasset(familyPath)local function face(weightName,fallback)local info=FONT_WEIGHTS[weightName]if info and weights[weightName]then
return Font.new(family,info[2])end
return fallback
end
Library.Fonts.Regular=face("Medium",face("Regular",Library.Fonts.Regular))Library.Fonts.Medium=face("SemiBold",face("Medium",Library.Fonts.Medium))Library.Fonts.Bold=face("Bold",face("SemiBold",Library.Fonts.Bold))return true
end
function Library:PreloadIcons()return loadLucide()~=false
end
local function resolveIcon(icon)if typeof(icon)=="table" then
local image=icon.Image or icon.Icon or icon.Name
if type(image)=="string" and not image:find("^rbxassetid://")and not image:find("^rbxasset://")and not image:find("^http")then
icon=image
else
return image,icon.RectOffset,icon.RectSize
end
end
if type(icon)~="string" then
return nil
end
if icon:find("^rbxassetid://")or icon:find("^rbxasset://")or icon:find("^http")then
return icon
end
local name=icon:gsub("^lucide:","")local set=loadLucide()if not set then
return nil
end
local lowerName=name:lower()local entry=(set.Icons and(set.Icons[name]or set.Icons[lowerName]))or set[name]or set[lowerName]if type(entry)=="table" then
local image=entry.Image
if type(image)=="number" then
image="rbxassetid://"..tostring(image)end
local sheet=(set.Spritesheets and set.Spritesheets[tostring(image)])or image
return sheet,entry.ImageRectPosition,entry.ImageRectSize
elseif type(entry)=="string" then
return entry
end
return nil
end
local BUTTON_HINT_ICON="chevron-right"
Library.Fonts={Regular=Font.fromEnum(Enum.Font.Nunito),Medium=Font.fromName("Nunito",Enum.FontWeight.Medium,Enum.FontStyle.Normal),Bold=Font.fromName("Nunito",Enum.FontWeight.Bold,Enum.FontStyle.Normal),}local Theme=Library.Theme
local Assets=Library.Assets
local Fonts=Library.Fonts
local TOUCH=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
Library.Touch=TOUCH
local SIDEBAR_WIDTH=170
local HEADER_HEIGHT=72
local CARD_HEIGHT=TOUCH and 54 or 48
local CARD_HEIGHT_DESC=TOUCH and 70 or 64
local DROPDOWN_OPTION_HEIGHT=32
local CHIP_HEIGHT=TOUCH and 34 or 28
local tweenInfoCache={}local function tween(object,props,duration,style,direction)duration=duration or 0.2
if duration<=0 then
for key,value in pairs(props)do
object[key]=value
end
return nil
end
style=style or Enum.EasingStyle.Quart
direction=direction or Enum.EasingDirection.Out
local key=duration..style.Name..direction.Name
local info=tweenInfoCache[key]if not info then
info=TweenInfo.new(duration,style,direction)tweenInfoCache[key]=info
end
local t=TweenService:Create(object,info,props)t:Play()return t
end
local TEXT_RENDER_SCALE=1.02
local function create(className,props,children)local inst=Instance.new(className)for key,value in pairs(props)do
if key~="Parent" then
if key=="TextSize"
and(className=="TextLabel" or className=="TextButton" or className=="TextBox")and type(value)=="number" then
value=math.max(1,math.floor(value*TEXT_RENDER_SCALE+0.5))end
inst[key]=value
end
end
if children then
for _,child in ipairs(children)do
child.Parent=inst
end
end
if props.Parent then
inst.Parent=props.Parent
end
return inst
end
local function corner(parent,radius)return create("UICorner",{CornerRadius=radius or UDim.new(0,8),Parent=parent,})end
local CARD_GROUP_CORNER_RADIUS=8
local function syncGroupCornerPatches(surface)for _,child in ipairs(surface:GetChildren())do
if child:GetAttribute("JinHubGroupCornerPatch")then
child.BackgroundColor3=surface.BackgroundColor3
child.BackgroundTransparency=surface.BackgroundTransparency
end
end
end
local function setGroupSurfacePosition(surface,position)local surfaceCorner=surface:FindFirstChildOfClass("UICorner")if not surfaceCorner then
surfaceCorner=corner(surface)end
surfaceCorner.CornerRadius=UDim.new(0,position=="Middle" and 0 or CARD_GROUP_CORNER_RADIUS)surface:SetAttribute("JinHubCardGroupPosition",position)for _,child in ipairs(surface:GetChildren())do
if child:GetAttribute("JinHubGroupCornerPatch")then
child:Destroy()end
end
local squareEdge=position=="First" and "Bottom" or position=="Last" and "Top" or nil
if squareEdge then
for _,isRight in ipairs({false,true})do
local patch=create("Frame",{Name="CardGroupSquareCornerPatch",Position=UDim2.new(isRight and 1 or 0,isRight and-CARD_GROUP_CORNER_RADIUS or 0,squareEdge=="Bottom" and 1 or 0,squareEdge=="Bottom" and-CARD_GROUP_CORNER_RADIUS or 0),Size=UDim2.fromOffset(CARD_GROUP_CORNER_RADIUS,CARD_GROUP_CORNER_RADIUS),BackgroundColor3=surface.BackgroundColor3,BackgroundTransparency=surface.BackgroundTransparency,BorderSizePixel=0,ZIndex=surface.ZIndex+1,Active=false,Parent=surface,})patch:SetAttribute("JinHubGroupCornerPatch",true)end
end
if not surface:GetAttribute("JinHubGroupPatchSyncConnected")then
surface:SetAttribute("JinHubGroupPatchSyncConnected",true)surface:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()syncGroupCornerPatches(surface)end)surface:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()syncGroupCornerPatches(surface)end)end
end
local function setCardGroupPosition(cardFrame,position)setGroupSurfacePosition(cardFrame,position)for _,descendant in ipairs(cardFrame:GetDescendants())do
if descendant:GetAttribute("JinHubLockedOverlay")then
setGroupSurfacePosition(descendant,position)end
end
end
local function stroke(parent,color,transparency,thickness)return create("UIStroke",{Color=color or Theme.Stroke,Transparency=transparency or 0,Thickness=thickness or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=parent,})end
local function padding(parent,left,right,top,bottom)return create("UIPadding",{PaddingLeft=UDim.new(0,left or 0),PaddingRight=UDim.new(0,right or 0),PaddingTop=UDim.new(0,top or 0),PaddingBottom=UDim.new(0,bottom or 0),Parent=parent,})end
local function label(props)local defaults={BackgroundTransparency=1,TextColor3=Theme.Text,TextSize=16,FontFace=Fonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,}for key,value in pairs(props)do
defaults[key]=value
end
return create("TextLabel",defaults)end
local function glow(parent,size,position,transparency,rotation)local image=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=position,Size=size,BackgroundTransparency=1,Image=Assets.Glow,ImageColor3=Color3.fromRGB(226,218,230),ImageTransparency=transparency,ZIndex=0,Parent=parent,})create("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(255,255,255),Theme.Accent),Rotation=rotation or 90,Parent=image,})return image
end
local function edgeHighlight(parent)return create("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.93,BorderSizePixel=0,ZIndex=0,Parent=parent,})end
local function applyIcon(imageLabel,icon)local image,rectOffset,rectSize=resolveIcon(icon)if not image then
return
end
imageLabel.Image=image
imageLabel.ImageRectOffset=rectOffset or Vector2.zero
imageLabel.ImageRectSize=rectSize or Vector2.zero
end
applyLocked=function(frame,window)local zIndex=frame.ZIndex
for _,descendant in ipairs(frame:GetDescendants())do
if descendant:IsA("GuiObject")then
zIndex=math.max(zIndex,descendant.ZIndex)end
end
local overlay=create("TextButton",{Name="LockedOverlay",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.38,BorderSizePixel=0,Text="",AutoButtonColor=false,Active=true,Selectable=false,ZIndex=zIndex+1,Parent=frame,})overlay:SetAttribute("JinHubLockedOverlay",true)local badge=create("Frame",{Name="LockedBadge",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(116,34),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=zIndex+2,Parent=overlay,})corner(badge,UDim.new(0,8))local lockIcon=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,11,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=Theme.Muted,ScaleType=Enum.ScaleType.Fit,ZIndex=zIndex+3,Parent=badge,})applyIcon(lockIcon,"lock")create("TextLabel",{Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-42,1,0),BackgroundTransparency=1,Text="Locked",TextColor3=Theme.Text,TextSize=15,FontFace=Fonts.Medium,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=zIndex+3,Parent=badge,})local frameCorner=frame:FindFirstChildOfClass("UICorner")if frameCorner then
corner(overlay,frameCorner.CornerRadius)end
local groupPosition=frame:GetAttribute("JinHubCardGroupPosition")if groupPosition then
setGroupSurfacePosition(overlay,groupPosition)end
end
local function defaultParent()local hidden
pcall(function()if typeof(gethui)=="function" then
hidden=gethui()end
end)if typeof(hidden)=="Instance" then
return hidden
end
local core
pcall(function()core=game:GetService("CoreGui")local probe=Instance.new("Folder")probe.Parent=core
probe:Destroy()end)if core then
return core
end
return LocalPlayer:WaitForChild("PlayerGui")end
local insetFrame,insetValue=nil,Vector2.zero
local function pointerPosition()local frame=time()if insetFrame~=frame then
insetFrame=frame
insetValue=GuiService:GetGuiInset()end
return UserInputService:GetMouseLocation()-insetValue
end
local function isPress(input)return input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch
end
local function isMove(input)return input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch
end
local function glowIcon(parent,icon,color,position)local holder=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=position,Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,Parent=parent,})local image=create("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageColor3=color,ScaleType=Enum.ScaleType.Fit,Parent=holder,})applyIcon(image,icon)return holder,image
end
local function arrowIndicator(parent,anchorX,offsetX)local holder=create("Frame",{AnchorPoint=Vector2.new(anchorX,0.5),Position=UDim2.new(anchorX,offsetX,0.5,0),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,Parent=parent,})local indicator={}local image=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=Theme.Muted,ScaleType=Enum.ScaleType.Fit,Parent=holder,})applyIcon(image,"chevron-down")if image.Image~="" then
function indicator:Set(open)tween(image,{Rotation=open and 180 or 0,ImageColor3=open and Theme.Accent or Theme.Muted,},0.3,Enum.EasingStyle.Quint)end
return indicator
end
image:Destroy()local function glyph(rotation,transparency)return label({AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(18,18),Text="›",TextSize=23,TextXAlignment=Enum.TextXAlignment.Center,TextColor3=Theme.Muted,TextTransparency=transparency,Rotation=rotation,Parent=holder,})end
local down=glyph(90,0)local up=glyph(270,1)function indicator:Set(open)tween(down,{TextTransparency=open and 1 or 0},0.2)tween(up,{TextTransparency=open and 0 or 1,TextColor3=open and Theme.Accent or Theme.Muted},0.2)end
return indicator
end
local ripplePool={}local function ripple(button)local mouse=pointerPosition()local diameter=math.max(button.AbsoluteSize.X,button.AbsoluteSize.Y)*2.2
local circle=table.remove(ripplePool)if not circle then
circle=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Theme.Accent,BorderSizePixel=0,})corner(circle,UDim.new(1,0))end
circle.Position=UDim2.fromOffset(mouse.X-button.AbsolutePosition.X,mouse.Y-button.AbsolutePosition.Y)circle.Size=UDim2.fromOffset(0,0)circle.BackgroundTransparency=0.82
circle.ZIndex=button.ZIndex+1
circle.Parent=button
tween(circle,{Size=UDim2.fromOffset(diameter,diameter),BackgroundTransparency=1},0.55)task.delay(0.55,function()circle.Parent=nil
if #ripplePool<4 then
table.insert(ripplePool,circle)else
circle:Destroy()end
end)end
local function flashStroke(strokeObject)if not strokeObject then
return
end
if strokeObject.Parent and strokeObject.Parent:GetAttribute("JinHubFlatSectionElement")and not strokeObject.Parent:GetAttribute("JinHubNewElements")then
return
end
local baseTransparency=strokeObject.Transparency
local baseColor=strokeObject.Color
tween(strokeObject,{Color=Theme.Accent,Transparency=0.2},0.08)task.delay(0.12,function()tween(strokeObject,{Color=baseColor,Transparency=baseTransparency},0.35)end)end
local function hoverStroke(target,strokeObject,isEnabled)if target:GetAttribute("JinHubFlatSectionElement")then
return
end
local baseTransparency=strokeObject.Transparency
target.MouseEnter:Connect(function()if isEnabled and not isEnabled()then
return
end
tween(strokeObject,{Color=Theme.StrokeHover,Transparency=math.min(baseTransparency,0.18),},0.12)end)target.MouseLeave:Connect(function()tween(strokeObject,{Color=Theme.Stroke,Transparency=baseTransparency,},0.25)end)end
local KEY_NAMES={[Enum.KeyCode.LeftControl]="LCtrl",[Enum.KeyCode.RightControl]="RCtrl",[Enum.KeyCode.LeftShift]="LShift",[Enum.KeyCode.RightShift]="RShift",[Enum.KeyCode.LeftAlt]="LAlt",[Enum.KeyCode.RightAlt]="RAlt",[Enum.KeyCode.Return]="Enter",[Enum.KeyCode.Escape]="Esc",[Enum.KeyCode.Backspace]="Backspace",}local function keyName(keyCode)if keyCode==nil then
return "None"
end
return KEY_NAMES[keyCode]or keyCode.Name
end
local function safeCall(callback,...)if type(callback)~="function" then
return
end
pcall(callback,...)end
local function numberFormat(min,max,step)local decimals=0
local text=tostring(step)local dot=text:find("%.")if dot then
decimals=#text-dot
end
local pattern="%."..decimals.."f"
return{snap=function(value)value=math.floor(value/step+0.5)*step
return math.clamp(value,min,max)end,format=function(value)return string.format(pattern,value)end,}end
local function card(tab,className,height,opts)local flatSectionElement=tab._flatElements==true
local compactSectionElement=tab._compactElements==true
local newElements=tab.Window and tab.Window.NewElements==true
if compactSectionElement and height>0 then
local reduction=height<=CARD_HEIGHT and 14 or 8
height=math.max(height-reduction,34)end
local props={Size=UDim2.new(1,0,0,height),BackgroundColor3=Theme.Surface2,BackgroundTransparency=flatSectionElement and not newElements and 1 or 0,BorderSizePixel=0,LayoutOrder=tab:_nextOrder(),Parent=tab.List,}if className=="TextButton" then
props.AutoButtonColor=false
props.Text=""
end
local frame=create(className,props)frame:SetAttribute("NoDrag",true)frame:SetAttribute("JinHubFlatSectionElement",flatSectionElement)frame:SetAttribute("JinHubNewElements",newElements)local showBoxBorder=tab._boxBorderElements==true and not flatSectionElement
frame:SetAttribute("JinHubBoxBorderElement",showBoxBorder)local frameCorner=corner(frame)local frameStrokeTransparency=(flatSectionElement or(newElements and not showBoxBorder))and 1 or 0
local frameStroke=stroke(frame,Theme.Stroke,frameStrokeTransparency)if newElements then
local window=tab.Window
window._groupOf=window._groupOf or{}window._groupCount=window._groupCount or{}window._groupMembers=window._groupMembers or{}frameStroke.ZIndex=frame.ZIndex+1
local previous,previousOrder
for _,sibling in ipairs(tab.List:GetChildren())do
if sibling~=frame and sibling:IsA("GuiObject")and sibling.LayoutOrder<frame.LayoutOrder
and(previousOrder==nil or sibling.LayoutOrder>previousOrder)then
previous=sibling
previousOrder=sibling.LayoutOrder
end
end
local previousIsGroupable=previous~=nil and(previous:GetAttribute("JinHubNewElements")==true
or previous:GetAttribute("JinHubCardGroup")==true)if previousIsGroupable then
local function parentMember(container,member)member.LayoutOrder=(window._groupCount[container]or 0)+1
window._groupCount[container]=member.LayoutOrder
member.Parent=container
window._groupOf[member]=container
local memberStroke=member:FindFirstChildOfClass("UIStroke")if memberStroke then
memberStroke.Transparency=1
end
local members=window._groupMembers[container]table.insert(members,member)end
local function appendMember(container,member)local members=window._groupMembers[container]if #members>1 then
setCardGroupPosition(members[#members],"Middle")end
parentMember(container,member)setCardGroupPosition(member,"Last")end
local groupContainer=previous:GetAttribute("JinHubCardGroup")and previous or window._groupOf[previous]if not groupContainer then
groupContainer=create("Frame",{Name="CardGroup",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false,LayoutOrder=previous.LayoutOrder,Parent=tab.List,})groupContainer:SetAttribute("NoDrag",true)groupContainer:SetAttribute("JinHubCardGroup",true)window._groupMembers[groupContainer]={}corner(groupContainer,UDim.new(0,CARD_GROUP_CORNER_RADIUS))stroke(groupContainer,Theme.Stroke,frameStrokeTransparency)create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=groupContainer,})parentMember(groupContainer,previous)setCardGroupPosition(previous,"First")end
appendMember(groupContainer,frame)end
end
return frame,frameStroke,height
end
local function titleDesc(parent,name,desc,rightReserve)local title,descLabel
local inset=parent:GetAttribute("JinHubFlatSectionElement")and 8 or 14
if desc then
local top=(CARD_HEIGHT_DESC-38)/2
title=label({Position=UDim2.fromOffset(inset,top),Size=UDim2.new(1,-(inset+rightReserve),0,18),Text=name,TextSize=16,FontFace=Fonts.Medium,Parent=parent,})descLabel=label({Position=UDim2.fromOffset(inset,top+20),Size=UDim2.new(1,-(inset+rightReserve),0,17),Text=desc,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=parent,})else
title=label({Position=UDim2.fromOffset(inset,0),Size=UDim2.new(1,-(inset+rightReserve),1,0),Text=name,TextSize=16,FontFace=Fonts.Medium,Parent=parent,})end
return title,descLabel
end
local function beginElement(tab,opts,map,className,rightReserve,fallbackName,heightOverride)opts=normalize(opts,map)local height=heightOverride or(opts.Desc and CARD_HEIGHT_DESC or CARD_HEIGHT)local frame,frameStroke
frame,frameStroke,height=card(tab,className or "Frame",height,opts)hoverStroke(frame,frameStroke)local title,descLabel
if rightReserve then
title,descLabel=titleDesc(frame,opts.Name or fallbackName,opts.Desc,rightReserve)end
return opts,frame,frameStroke,height,title,descLabel
end
local function reserveRight(title,descLabel,width)if title then
title.Size=UDim2.new(1,-(14+width),title.Size.Y.Scale,title.Size.Y.Offset)end
if descLabel then
descLabel.Size=UDim2.new(1,-(14+width),0,descLabel.Size.Y.Offset)end
end
local Tab={}Tab.__index=Tab
local HStack={}HStack.__index=HStack
function Tab:_nextOrder()self._order=self._order+1
return self._order
end
function Tab:HStack()local frame=create("Frame",{Name="HStack",Size=UDim2.new(1,0,0,1),BackgroundTransparency=1,LayoutOrder=self:_nextOrder(),Parent=self.List,})frame:SetAttribute("NoDrag",true)create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=frame,})return setmetatable({Tab=self,Frame=frame,Columns={},ColumnLayouts={},SectionOwner=self._sectionOwner,FlatElements=self._flatElements,BoxBorderElements=self._boxBorderElements,CompactElements=true,},HStack)end
function HStack:_updateHeight()local naturalHeight=0
for _,layout in ipairs(self.ColumnLayouts)do
naturalHeight=math.max(naturalHeight,layout.AbsoluteContentSize.Y)end
local scale=math.max(self.Tab.Window.Scale.Scale,0.001)local availableHeight=self.Tab.List:IsA("ScrollingFrame")and self.Tab.List.AbsoluteWindowSize.Y/scale
or 0
if availableHeight<=0 then
availableHeight=(self.Tab.Window.Body.AbsoluteSize.Y-HEADER_HEIGHT-24)/scale
end
availableHeight=math.max(1,availableHeight)self.Frame.Size=UDim2.new(1,0,0,math.max(1,math.min(naturalHeight,availableHeight)))end
function HStack:VStack()local index=#self.Columns+1
local column=create("ScrollingFrame",{Name="VStack"..index,Size=UDim2.new(1/index,-8*(index-1)/index,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.Y,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Active=true,LayoutOrder=index,Parent=self.Frame,})local layout=create("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,self.Tab.Window.NewElements and 0 or 2),Parent=column,})table.insert(self.Columns,column)table.insert(self.ColumnLayouts,layout)local count=#self.Columns
for _,existing in ipairs(self.Columns)do
existing.Size=UDim2.new(1/count,-8*(count-1)/count,1,0)end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()self:_updateHeight()end)self.Tab.List:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()self:_updateHeight()end)self:_updateHeight()return setmetatable({Name=self.Tab.Name,Window=self.Tab.Window,List=column,_order=0,_hstack=self,_sectionOwner=self.SectionOwner,_flatElements=self.FlatElements,_boxBorderElements=self.BoxBorderElements,_compactElements=true,},Tab)end
function Tab:Section(text)if type(text)=="table" then
local opts=normalize(text,{Name="Title",Boxborder="BoxBorder"})local titleText=opts.Title or opts.Name or "Section"
local opened=opts.Opened==true
local boxed=opts.Box==true
local boxBorder=opts.BoxBorder
if boxBorder==nil then
boxBorder=opts.Boxborder
end
if boxBorder==nil then
boxBorder=boxed
end
local elementBox=opts.ElementBox
if elementBox==nil then
elementBox=boxed
end
local flatChildren=self._flatElements or not elementBox
local boxBorderChildren=elementBox and not flatChildren
local holder=create("Frame",{Name="Section",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.Surface2,BackgroundTransparency=boxed and 0 or 1,BorderSizePixel=0,LayoutOrder=self:_nextOrder(),Parent=self.List,})holder:SetAttribute("NoDrag",true)holder.ClipsDescendants=boxed
corner(holder,UDim.new(0,11))local holderStroke=stroke(holder,Theme.Stroke,boxed and boxBorder and 0 or 1)local sectionSpacer=create("Frame",{Name="SectionSpacing",Size=UDim2.new(1,0,0,boxed and 8 or 2),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=self:_nextOrder(),Parent=self.List,})holder.Destroying:Connect(function()if sectionSpacer.Parent then
sectionSpacer:Destroy()end
end)local headerColor=Theme.Surface2:Lerp(Theme.Surface3,0.4)local header=create("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=headerColor,BackgroundTransparency=boxed and 0 or 1,Text="",AutoButtonColor=false,ZIndex=2,Parent=holder,})header:SetAttribute("NoDrag",true)local headerBottomFillLeft,headerBottomFillRight
if boxed then
corner(header,UDim.new(0,11))local bottomRadius=11
headerBottomFillLeft=create("Frame",{Name="HeaderBottomFillLeft",Position=UDim2.new(0,0,1,-bottomRadius),Size=UDim2.fromOffset(bottomRadius,bottomRadius),BackgroundColor3=headerColor,BorderSizePixel=0,ZIndex=header.ZIndex,Visible=opened,Parent=header,})headerBottomFillRight=create("Frame",{Name="HeaderBottomFillRight",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,1,-bottomRadius),Size=UDim2.fromOffset(bottomRadius,bottomRadius),BackgroundColor3=headerColor,BorderSizePixel=0,ZIndex=header.ZIndex,Visible=opened,Parent=header,})end
local titleLeft=14
if opts.Icon then
local icon=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=Theme.Accent,ScaleType=Enum.ScaleType.Fit,ZIndex=3,Parent=header,})applyIcon(icon,opts.Icon)titleLeft=36
end
local fontWeight=opts.FontWeight
local titleFont=fontWeight=="Regular" and Fonts.Regular
or fontWeight=="Medium" and Fonts.Medium
or Fonts.Bold
local textAlignment=Enum.TextXAlignment.Left
if type(opts.TextXAlignment)=="string" then
textAlignment=Enum.TextXAlignment[opts.TextXAlignment]or textAlignment
elseif typeof(opts.TextXAlignment)=="EnumItem" then
textAlignment=opts.TextXAlignment
end
local title=label({Position=UDim2.new(0,titleLeft,0,0),Size=UDim2.new(1,-(titleLeft+44),1,0),Text=tostring(titleText),TextSize=opts.TextSize or 17,TextTransparency=opts.TextTransparency==nil and 0.05 or opts.TextTransparency,FontFace=titleFont,TextXAlignment=textAlignment,ZIndex=3,Parent=header,})local arrow=arrowIndicator(header,1,-14)arrow:Set(opened)local content=create("Frame",{Name="SectionContent",Position=UDim2.fromOffset(0,38),Size=UDim2.new(1,0,0,0),AutomaticSize=opened and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,BackgroundTransparency=1,Visible=opened,Parent=holder,})local sidePadding=boxBorder and(boxed and 4 or 0)or 0.1
padding(content,sidePadding,sidePadding,boxed and 1 or 0,boxed and 1 or 0)create("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,self.Window.NewElements and(boxBorderChildren and 2 or 0)or 2),Parent=content,})local hoverOutline
local hoverOutlineStroke
hoverOutline=create("Frame",{Name="SectionHoverOutline",Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=20,Parent=holder,})corner(hoverOutline,UDim.new(0,8))hoverOutlineStroke=stroke(hoverOutline,Theme.StrokeHover,1,1)local section=setmetatable({Name=tostring(titleText),Window=self.Window,List=content,_order=0,_hstack=self._hstack,_children={},_flatElements=flatChildren,_boxBorderElements=boxBorderChildren,_compactElements=true,},Tab)section._sectionOwner=section
local hovered=false
local baseStrokeTransparency=boxBorder and 0 or 1
local function pointerInsideSection(pointer)if not opened or not holder.Parent or not holder.Visible then
return false
end
if pointer==false then
return false
end
pointer=pointer or pointerPosition()local position=holder.AbsolutePosition
local size=holder.AbsoluteSize
if pointer.X<position.X or pointer.X>position.X+size.X
or pointer.Y<position.Y or pointer.Y>position.Y+size.Y then
return false
end
local ancestor=holder.Parent
while ancestor and ancestor~=self.Window.Body do
if ancestor:IsA("GuiObject")then
if not ancestor.Visible then
return false
end
if ancestor.ClipsDescendants or ancestor:IsA("ScrollingFrame")then
local clipPosition=ancestor.AbsolutePosition
local clipSize=ancestor.AbsoluteSize
if pointer.X<clipPosition.X or pointer.X>clipPosition.X+clipSize.X
or pointer.Y<clipPosition.Y or pointer.Y>clipPosition.Y+clipSize.Y then
return false
end
end
end
ancestor=ancestor.Parent
end
return true
end
local function setHovered(value)if hovered==value then
return
end
hovered=value
tween(holderStroke,{Color=hovered and Theme.StrokeHover or Theme.Stroke,Transparency=hovered and math.min(baseStrokeTransparency,0.18)or baseStrokeTransparency,},0.08)tween(hoverOutlineStroke,{Transparency=hovered and 0 or 1},0.08)end
local function setOpened(value)opened=value==true
content.Visible=opened
content.AutomaticSize=opened and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
content.Size=UDim2.new(1,0,0,0)arrow:Set(opened)if headerBottomFillLeft then
headerBottomFillLeft.Visible=opened
headerBottomFillRight.Visible=opened
end
if not opened then
setHovered(false)elseif self.Window._sectionHoverRefresh then
task.defer(self.Window._sectionHoverRefresh)end
end
function section:SetTitle(value)titleText=tostring(value or "")title.Text=titleText
section.Name=titleText
end
function section:Set(value)section:SetTitle(value)end
function section:SetOpen(value)setOpened(value)end
function section:GetOpen()return opened
end
header.MouseButton1Click:Connect(function()setOpened(not opened)end)self.Window:_registerSectionHover(function(pointer)setHovered(pointerInsideSection(pointer))end,section)return finishElement(self,opts,section,holder,"Section")end
local holder=create("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=self:_nextOrder(),Parent=self.List,})local text_=label({Position=UDim2.fromOffset(2,8),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=string.upper(text),TextSize=13,TextColor3=Theme.Muted,TextTruncate=Enum.TextTruncate.None,Parent=holder,})local rule=create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0,16),Size=UDim2.new(1,-12,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,Parent=holder,})text_:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()rule.Size=UDim2.new(1,-(text_.AbsoluteSize.X+14),0,1)end)task.defer(function()rule.Size=UDim2.new(1,-(text_.AbsoluteSize.X+14),0,1)end)return finishElement(self,{},{Set=function(_,value)text_.Text=string.upper(value)end,},holder,"Section")end
function Tab:Divider()local newElements=self.Window and self.Window.NewElements==true
local line
if newElements then
local spacer=create("Frame",{Size=UDim2.new(1,0,0,7),BackgroundTransparency=1,LayoutOrder=self:_nextOrder(),Parent=self.List,})line=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,Parent=spacer,})spacer:SetAttribute("NoDrag",true)return finishElement(self,{},{},spacer,"Divider")end
line=create("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,LayoutOrder=self:_nextOrder(),Parent=self.List,})return finishElement(self,{},{},line,"Divider")end
function Tab:Label(opts)opts=normalize(opts,{Name="Text",Title="Text"})local text_=label({Size=UDim2.new(1,0,0,18),Text=opts.Text or "",TextSize=16,FontFace=Fonts.Regular,TextColor3=opts.Color or Theme.Muted,LayoutOrder=self:_nextOrder(),Parent=self.List,})padding(text_,2)local handle={Set=function(_,value)text_.Text=tostring(value)end,Get=function()return text_.Text
end,}if type(opts.Update)=="function" then
local rate=math.max(tonumber(opts.UpdateRate)or 1,0.05)local running=true
handle._listeners=handle._listeners or{}table.insert(handle._listeners,function()running=false
end)task.spawn(function()while running and text_.Parent do
local ok,value=pcall(opts.Update)if ok and value~=nil then
text_.Text=tostring(value)end
task.wait(rate)end
end)function handle:SetUpdateRate(seconds)rate=math.max(tonumber(seconds)or rate,0.05)end
end
return finishElement(self,opts,handle,text_,"Label")end
function Tab:Paragraph(opts)opts=normalize(opts,{Title="Name"})local frame=card(self,"Frame",0,opts)frame.AutomaticSize=Enum.AutomaticSize.Y
padding(frame,14,14,11,12)create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=frame,})label({Size=UDim2.new(1,0,0,14),Text=opts.Name or "",LayoutOrder=1,Parent=frame,})local content=label({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=opts.Content or "",TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2,Parent=frame,})return finishElement(self,opts,{Set=function(_,value)content.Text=value
end,},frame,"Paragraph")end
function Tab:Button(opts)opts=normalize(opts,{Title="Name",Description="Desc"})local primary=opts.Style=="Primary"
local height=opts.Desc and CARD_HEIGHT_DESC or CARD_HEIGHT
local button,buttonStroke=card(self,"TextButton",height,opts)local flatSectionElement=button:GetAttribute("JinHubFlatSectionElement")==true
and not button:GetAttribute("JinHubNewElements")button.ClipsDescendants=true
if primary and not flatSectionElement then
local manualOutline=button:GetAttribute("JinHubNewElements")==true
button.BackgroundColor3=Theme.Accent
button.BackgroundTransparency=0.12
buttonStroke.Color=Theme.Accent
local hidePrimaryStroke=manualOutline and not button:GetAttribute("JinHubBoxBorderElement")buttonStroke.Transparency=hidePrimaryStroke and 1 or 0.4
button.MouseEnter:Connect(function()tween(button,{BackgroundTransparency=0},0.12)tween(buttonStroke,{Transparency=0},0.12)end)button.MouseLeave:Connect(function()tween(button,{BackgroundTransparency=0.12},0.25)tween(buttonStroke,{Transparency=hidePrimaryStroke and 1 or 0.4},0.25)end)elseif not flatSectionElement then
hoverStroke(button,buttonStroke)else
button.BackgroundTransparency=1
buttonStroke.Transparency=1
end
local textColor=primary and not flatSectionElement and Theme.AccentDark or Theme.Text
local iconOffset=0
if opts.Icon then
glowIcon(button,opts.Icon,primary and not flatSectionElement and Theme.AccentDark or Theme.Accent,UDim2.new(0,14,0.5,0))iconOffset=26
end
local title=titleDesc(button,opts.Name or "Button",opts.Desc,30)if iconOffset>0 then
for _,child in ipairs(button:GetChildren())do
if child:IsA("TextLabel")then
child.Position=child.Position+UDim2.fromOffset(iconOffset,0)child.Size=child.Size-UDim2.fromOffset(iconOffset,0)end
end
end
if primary then
for _,child in ipairs(button:GetChildren())do
if child:IsA("TextLabel")then
child.TextColor3=textColor
end
end
end
glowIcon(button,BUTTON_HINT_ICON,primary and not flatSectionElement and Theme.AccentDark or Theme.Muted,UDim2.new(1,-30,0.5,0))button.MouseButton1Click:Connect(function()ripple(button)safeCall(opts.Callback)end)return finishElement(self,opts,{SetText=function(_,value)title.Text=value
end,},button,"Button")end
function Tab:Toggle(opts)local button,buttonStroke
opts,button,buttonStroke=beginElement(self,opts,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default"},"TextButton",56,"Toggle")local pill=create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-14,0.5,0),Size=TOUCH and UDim2.fromOffset(44,24)or UDim2.fromOffset(36,20),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,Parent=button,})corner(pill,UDim.new(1,0))stroke(pill,Theme.Stroke)local knob=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=TOUCH and UDim2.fromOffset(18,18)or UDim2.fromOffset(14,14),BackgroundColor3=Theme.Muted,BorderSizePixel=0,Parent=pill,})corner(knob,UDim.new(1,0))local pillGlow=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,24,1,24),BackgroundTransparency=1,Image=Assets.Glow,ImageColor3=Theme.Accent,ImageTransparency=1,ZIndex=0,Parent=pill,})local self_={Value=opts.Default==true}local function render(animate)local on=self_.Value
local duration=animate and 0.25 or 0
tween(pill,{BackgroundColor3=on and Theme.Accent or Theme.Surface3},duration)tween(pillGlow,{ImageTransparency=on and 0.75 or 1},duration)local knobSize=TOUCH and 18 or 14
tween(knob,{Position=on and UDim2.new(0,(TOUCH and 44 or 36)-3-knobSize,0.5,0)or UDim2.new(0,3,0.5,0),BackgroundColor3=on and Theme.AccentDark or Theme.Muted,},duration,Enum.EasingStyle.Back)if animate then
tween(knob,{Size=UDim2.fromOffset(knobSize+4,knobSize-2)},0.08)task.delay(0.08,function()tween(knob,{Size=UDim2.fromOffset(knobSize,knobSize)},0.2,Enum.EasingStyle.Back)end)end
end
local fromClick=false
function self_:Set(value,silent)value=value==true
if value==self_.Value then
return
end
self_.Value=value
render(true)if not fromClick then
flashStroke(buttonStroke)end
if not silent then
safeCall(opts.Callback,value)end
end
function self_:Get()return self_.Value
end
render(false)button.MouseButton1Click:Connect(function()fromClick=true
self_:Set(not self_.Value)fromClick=false
end)local handle=finishElement(self,opts,self_,button,"Toggle")if self_.Value then
safeCall(opts.Callback,true)end
return handle
end
function Tab:Slider(opts)opts=normalize(opts,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default",Increment="Step"})local min=opts.Min or 0
local max=opts.Max or 100
local step=opts.Step or 1
local suffix=opts.Suffix or ""
local numbers=numberFormat(min,max,step)local flatSection=self._flatElements==true
local frame,frameStroke=card(self,"Frame",CARD_HEIGHT_DESC-(flatSection and 4 or 0),opts)hoverStroke(frame,frameStroke)local inset=frame:GetAttribute("JinHubFlatSectionElement")and 8 or 14
label({Position=UDim2.fromOffset(inset,12),Size=UDim2.new(1,-(inset+106),0,18),Text=opts.Name or "Slider",Parent=frame,})local valueChip=create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,frame:GetAttribute("JinHubFlatSectionElement")and-8 or-10,0,9),Size=UDim2.fromOffset(40,24),BackgroundColor3=Theme.Surface,BorderSizePixel=0,ClipsDescendants=true,Parent=frame,})corner(valueChip,UDim.new(0,6))local chipStroke=stroke(valueChip)local valueLabel=label({Size=UDim2.new(1,0,1,0),TextSize=16,TextColor3=Theme.Accent,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,Parent=valueChip,})local valueBox=create("TextBox",{Position=UDim2.fromOffset(9,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="",TextColor3=Theme.Text,TextSize=16,FontFace=Fonts.Medium,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Visible=false,Parent=valueChip,})create("UISizeConstraint",{MinSize=Vector2.new(14,0),Parent=valueBox})local suffixLabel=label({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=suffix,TextSize=16,TextColor3=Theme.Accent,TextTruncate=Enum.TextTruncate.None,Visible=false,Parent=valueChip,})local chipButton=create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=2,Parent=valueChip,})local editing=false
local function fitChip(instant)local width
if editing then
width=9+valueBox.AbsoluteSize.X/(self.Window.Scale.Scale)+suffixLabel.TextBounds.X+9
suffixLabel.Position=UDim2.fromOffset(9+valueBox.AbsoluteSize.X/(self.Window.Scale.Scale),0)else
width=valueLabel.TextBounds.X+18
end
width=math.max(width,36)if instant then
valueChip.Size=UDim2.fromOffset(width,24)else
tween(valueChip,{Size=UDim2.fromOffset(width,24)},0.2)end
end
valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()if not editing then
fitChip(false)end
end)valueBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()if editing then
fitChip(false)end
end)local sliderAccent=Theme.Accent
local track=create("Frame",{Position=UDim2.new(0,inset,0,CARD_HEIGHT_DESC-18),Size=UDim2.new(1,-(inset*2),0,5),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,Parent=frame,})corner(track,UDim.new(1,0))local fill=create("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=sliderAccent,BorderSizePixel=0,Parent=track,})corner(fill,UDim.new(1,0))local knobGlow=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,Image=Assets.Glow,ImageColor3=sliderAccent,ImageTransparency=0.85,ZIndex=2,Parent=track,})local knob=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(10,10),BackgroundColor3=Color3.fromRGB(238,236,239),BorderSizePixel=0,ZIndex=3,Parent=track,})corner(knob,UDim.new(0,2))for _,x in ipairs({3,6})do
create("Frame",{Position=UDim2.fromOffset(x,3),Size=UDim2.fromOffset(1,4),BackgroundColor3=Color3.fromRGB(91,86,94),BorderSizePixel=0,ZIndex=knob.ZIndex+1,Parent=knob,})end
local hit=create("TextButton",{Position=UDim2.new(0,8,0,CARD_HEIGHT_DESC-(TOUCH and 37 or 31)),Size=UDim2.new(1,-16,0,TOUCH and 40 or 28),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=frame,})local self_={Value=math.clamp(opts.Default or min,min,max)}local dragging=false
chipButton.MouseEnter:Connect(function()tween(chipStroke,{Color=Theme.StrokeHover},0.12)end)chipButton.MouseLeave:Connect(function()if not valueBox:IsFocused()then
tween(chipStroke,{Color=Theme.Stroke},0.2)end
end)chipButton.MouseButton1Click:Connect(function()editing=true
valueBox.Text=numbers.format(self_.Value)valueLabel.Visible=false
valueBox.Visible=true
suffixLabel.Visible=suffix~=""
chipButton.Visible=false
tween(chipStroke,{Color=Theme.StrokeHover},0.12)valueBox:CaptureFocus()task.defer(fitChip,false)end)valueBox.FocusLost:Connect(function()local typed=tonumber(valueBox.Text)editing=false
valueBox.Visible=false
suffixLabel.Visible=false
valueLabel.Visible=true
chipButton.Visible=true
tween(chipStroke,{Color=Theme.Stroke},0.2)if typed then
self_:Set(typed)end
fitChip(false)end)hit.MouseEnter:Connect(function()if not dragging then
tween(knobGlow,{ImageTransparency=0.78,Size=UDim2.fromOffset(34,34)},0.15)end
end)hit.MouseLeave:Connect(function()if not dragging then
tween(knobGlow,{ImageTransparency=0.85,Size=UDim2.fromOffset(28,28)},0.2)end
end)local snap=numbers.snap
local function fraction()return(max-min)==0 and 0 or(self_.Value-min)/(max-min)end
local function moveTo(frac,duration,style)style=style or Enum.EasingStyle.Linear
local knobPosition=UDim2.new(frac,6-(frac*12),0.5,0)tween(fill,{Size=UDim2.new(frac,0,1,0)},duration,style)tween(knob,{Position=knobPosition},duration,style)tween(knobGlow,{Position=knobPosition},duration,style)end
local function render(duration,style)moveTo(fraction(),duration,style)valueLabel.Text=numbers.format(self_.Value)..suffix
end
local function settleTo(previousFrac)local target=fraction()local width=math.max(track.AbsoluteSize.X,1)local overshoot=(target>=previousFrac and 1 or-1)*(5/width)moveTo(math.clamp(target+overshoot,0,1),0.22,Enum.EasingStyle.Quint)task.delay(0.22,function()if not dragging then
moveTo(fraction(),0.18,Enum.EasingStyle.Quint)end
end)valueLabel.Text=numbers.format(self_.Value)..suffix
end
local function bounceKnob()tween(knob,{Size=UDim2.fromOffset(12,10)},0.08)tween(knobGlow,{Size=UDim2.fromOffset(32,32),ImageTransparency=0.78},0.12)task.delay(0.1,function()tween(knob,{Size=UDim2.fromOffset(10,10)},0.25,Enum.EasingStyle.Quint)tween(knobGlow,{Size=UDim2.fromOffset(28,28),ImageTransparency=0.85},0.25)end)end
function self_:Set(value,silent)value=snap(tonumber(value)or min)if value==self_.Value then
return
end
local previousFrac=fraction()self_.Value=value
if dragging then
render(0.05)else
settleTo(previousFrac)bounceKnob()flashStroke(frameStroke)end
if not silent then
safeCall(opts.Callback,value)end
end
function self_:Get()return self_.Value
end
local function updateFromX(x)local frac=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)self_:Set(min+(max-min)*frac)end
hit.InputBegan:Connect(function(input)if isPress(input)then
dragging=true
tween(knob,{Size=UDim2.fromOffset(16,16)},0.15,Enum.EasingStyle.Back)tween(knobGlow,{Size=UDim2.fromOffset(44,44),ImageTransparency=0.7},0.15)updateFromX(pointerPosition().X)end
end)self.Window:_listen("Changed",function(input)if dragging and isMove(input)then
updateFromX(pointerPosition().X)end
end,self_)self.Window:_listen("Ended",function(input)if dragging and isPress(input)then
dragging=false
tween(knob,{Size=UDim2.fromOffset(12,12)},0.2)tween(knobGlow,{Size=UDim2.fromOffset(28,28),ImageTransparency=0.85},0.2)end
end,self_)self_.Value=snap(self_.Value)render(0)task.defer(fitChip,true)return finishElement(self,opts,self_,frame,"Slider")end
function Tab:Dropdown(opts)opts=normalize(opts,{Title="Name",Description="Desc",CurrentOption="Default",Value="Default",MultipleOptions="Multi",Values="Options"})if opts.Multi and type(opts.Default)~="table" and opts.Default~=nil then
opts.Default={opts.Default}elseif not opts.Multi and type(opts.Default)=="table" then
opts.Default=opts.Default[1]end
local multi=opts.Multi==true
local stacked=opts.Modern==true
local options=opts.Options or{}local frame,frameStroke,height
local stackedHeight
if stacked then
stackedHeight=(opts.Desc and(TOUCH and 92 or 84)or(TOUCH and 80 or 72))-(self._flatElements and 4 or 0)end
opts,frame,frameStroke,height=beginElement(self,opts,{},"Frame",nil,nil,stackedHeight)frame.ClipsDescendants=false
local stackedInset=frame:GetAttribute("JinHubFlatSectionElement")and 8 or 14
local chipInset=frame:GetAttribute("JinHubFlatSectionElement")and 8 or 10
local header=create("TextButton",{Size=UDim2.new(1,0,0,height),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=frame,})local titleLabel,descLabel
if stacked then
titleLabel=label({Position=UDim2.fromOffset(stackedInset,5),Size=UDim2.new(1,-(stackedInset*2),0,18),Text=opts.Name or "Dropdown",Parent=header,})if opts.Desc then
descLabel=label({Position=UDim2.fromOffset(stackedInset,23),Size=UDim2.new(1,-(stackedInset*2),0,16),Text=opts.Desc,TextSize=13,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=header,})end
else
titleLabel,descLabel=titleDesc(header,opts.Name or "Dropdown",opts.Desc,180)end
local chip=create("Frame",{AnchorPoint=stacked and Vector2.new(0,0)or Vector2.new(1,0.5),Position=stacked
and UDim2.new(0,chipInset,0,(opts.Desc and(TOUCH and 48 or 46)or(TOUCH and 33 or 29))-(frame:GetAttribute("JinHubFlatSectionElement")and 4 or 0)+4)or UDim2.new(1,-chipInset,0.5,0),Size=stacked and UDim2.new(1,-(chipInset*2),0,CHIP_HEIGHT)or UDim2.fromOffset(60,CHIP_HEIGHT),BackgroundColor3=Theme.Surface,BackgroundTransparency=0,BorderSizePixel=0,ClipsDescendants=true,Parent=header,})corner(chip,UDim.new(0,8))local chipStroke=stroke(chip,Theme.Stroke,0.18,1)create("Frame",{Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,Parent=chip,})local valueLabel=label({Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-34,1,0),TextColor3=Theme.Text,TextSize=16,TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=chip,})local arrow=arrowIndicator(chip,1,-6)local measure=label({Size=UDim2.fromOffset(0,CHIP_HEIGHT),AutomaticSize=Enum.AutomaticSize.X,TextSize=16,Visible=false,Parent=chip,})local fullText=""
local function trimmed()local maxText=stacked and math.max(40,frame.AbsoluteSize.X-64)or(190-10-34)measure.Text=fullText
if measure.TextBounds.X<=maxText then
return fullText
end
local text=fullText
while #text>1 do
text=text:sub(1,-2)measure.Text=text..".."
if measure.TextBounds.X<=maxText then
return text..".."
end
end
return ".."
end
local function fitChip(instant)if stacked then
local size=UDim2.new(1,-(chipInset*2),0,CHIP_HEIGHT)if instant then
chip.Size=size
else
tween(chip,{Size=size},0.2)end
return
end
local width=math.clamp(valueLabel.TextBounds.X+10+34,60,190)reserveRight(titleLabel,descLabel,width+20)if instant then
chip.Size=UDim2.fromOffset(width,CHIP_HEIGHT)else
tween(chip,{Size=UDim2.fromOffset(width,CHIP_HEIGHT)},0.2)end
end
valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()fitChip(false)end)local self_={Open=false,_listeners={}}local window=self.Window
window._openDropdown=window._openDropdown or nil
local selected={}local optionButtons={}local filter=""
local SEARCH_HEIGHT=TOUCH and 42 or 40
local OPTION_GAP=0
local SELECT_ACTION_HEIGHT=TOUCH and 34 or 30
local SELECT_ACTION_GAP=6
local showSelectAll=multi and opts.SelectAll==true
local optionScrollerTop=SEARCH_HEIGHT+18
local optionScrollerBottomReserve=10
local renderValueLabel,currentValue,setOpen
if showSelectAll then
optionScrollerBottomReserve+=SELECT_ACTION_HEIGHT+SELECT_ACTION_GAP
end
local POPUP_MIN_HEIGHT=TOUCH and 116 or 106
local POPUP_MAX_HEIGHT=TOUCH and 360 or 330
local POPUP_MIN_WIDTH=TOUCH and 230 or 220
local POPUP_MAX_WIDTH=TOUCH and 280 or 265
local POPUP_VERTICAL_OFFSET=4
local popup=create("Frame",{Name="DropdownPopover",Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(POPUP_MIN_WIDTH,POPUP_MIN_HEIGHT),BackgroundColor3=Theme.Background:Lerp(Theme.Accent,0.075),BackgroundTransparency=0,BorderSizePixel=0,ClipsDescendants=true,Visible=false,ZIndex=1000,Parent=self.Window.Root,})popup:SetAttribute("NoDrag",true)popup:SetAttribute("JinHubDropdownPopup",true)corner(popup,UDim.new(0,13))local popupShadow=create("ImageLabel",{Name="DropdownPopoverShadow",Position=UDim2.fromOffset(-16,-16),Size=UDim2.new(1,32,1,32),BackgroundTransparency=1,Image=Assets.Shadow,ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.52,Visible=false,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=999,Parent=self.Window.Root,})popupShadow:SetAttribute("JinHubDropdownPopup",true)local popupStroke=stroke(popup,Color3.fromRGB(112,88,119),1,1)local popupInnerStroke=stroke(popup,Color3.fromRGB(255,255,255),1,1)create("Frame",{Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,0,1),BackgroundColor3=Theme.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1002,Parent=popup,})local searchHolder=create("Frame",{Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-20,0,SEARCH_HEIGHT),BackgroundColor3=Theme.Surface,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=1001,Parent=popup,})corner(searchHolder,UDim.new(0,10))local searchStroke=stroke(searchHolder,Color3.fromRGB(94,78,101),0.45,1)local searchIcon=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,11,0.5,0),Size=UDim2.fromOffset(15,15),BackgroundTransparency=1,ImageColor3=Color3.fromRGB(145,135,151),ZIndex=1003,Parent=searchHolder,})applyIcon(searchIcon,"search")local searchBox=create("TextBox",{Position=UDim2.fromOffset(35,0),Size=UDim2.new(1,-43,1,0),BackgroundTransparency=1,Text="",PlaceholderText="Search values....",PlaceholderColor3=Color3.fromRGB(112,103,116),TextColor3=Theme.Text,TextSize=16,FontFace=Fonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=1003,Parent=searchHolder,})if showSelectAll then
local actionRow=create("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-10),Size=UDim2.new(1,-20,0,SELECT_ACTION_HEIGHT),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1001,Parent=popup,})local actionGroup=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=1001,Parent=actionRow,})local function makeSelectAction(name,text,position,size,primary,roundedSide)local button=create("TextButton",{Name=name,Position=position,Size=size,BackgroundColor3=primary and Theme.Accent or Theme.Surface3,BackgroundTransparency=0,BorderSizePixel=0,AutoButtonColor=false,Text=text,TextColor3=primary and Theme.AccentDark or Theme.Muted,TextSize=13,FontFace=Fonts.Medium,ZIndex=1002,Parent=actionGroup,})if roundedSide then
corner(button,UDim.new(0,6))local radius=6
local squareX=roundedSide=="left" and 1 or 0
local squareXOffset=roundedSide=="left" and-radius or 0
for _,atBottom in ipairs({false,true})do
local fill=create("Frame",{Position=UDim2.new(squareX,squareXOffset,atBottom and 1 or 0,atBottom and-radius or 0),Size=UDim2.fromOffset(radius,radius),BackgroundColor3=button.BackgroundColor3,BackgroundTransparency=button.BackgroundTransparency,BorderSizePixel=0,ZIndex=button.ZIndex+1,Parent=button,})button:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()fill.BackgroundColor3=button.BackgroundColor3
end)button:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()fill.BackgroundTransparency=button.BackgroundTransparency
end)end
end
button.MouseEnter:Connect(function()tween(button,{BackgroundColor3=primary and Color3.fromRGB(245,224,250)or Theme.Surface3:Lerp(Theme.Text,0.08),BackgroundTransparency=0,TextColor3=primary and Theme.AccentDark or Theme.Text,},0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)end)button.MouseLeave:Connect(function()tween(button,{BackgroundColor3=primary and Theme.Accent or Theme.Surface3,BackgroundTransparency=0,TextColor3=primary and Theme.AccentDark or Theme.Muted,},0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)end)return button
end
local selectAllButton=makeSelectAction("SelectAllButton","Select All",UDim2.new(0,0,0,0),UDim2.new(0.31,-1,1,0),false,"left")local unselectAllButton=makeSelectAction("UnselectAllButton","Unselect All",UDim2.new(0.31,1,0,0),UDim2.new(0.43,-2,1,0),false,nil)local doneButton=makeSelectAction("DoneButton","Done",UDim2.new(0.74,1,0,0),UDim2.new(0.26,-1,1,0),true,"right")selectAllButton.MouseButton1Click:Connect(function()selected={}for _,option in ipairs(options)do
selected[option]=true
end
renderValueLabel()flashStroke(frameStroke)safeCall(opts.Callback,currentValue())end)unselectAllButton.MouseButton1Click:Connect(function()selected={}renderValueLabel()flashStroke(frameStroke)safeCall(opts.Callback,currentValue())end)doneButton.MouseButton1Click:Connect(function()setOpen(false)end)end
local optionScroller=create("ScrollingFrame",{Position=UDim2.fromOffset(10,optionScrollerTop),Size=UDim2.new(1,-24,1,-(optionScrollerTop+optionScrollerBottomReserve)),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=TOUCH and 4 or 3,ScrollBarImageColor3=Theme.Accent,ScrollBarImageTransparency=0.08,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=1001,Parent=popup,})create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,OPTION_GAP),Parent=optionScroller,})local function matches(option)return filter=="" or string.find(string.lower(tostring(option)),filter,1,true)~=nil
end
if multi then
for _,value in ipairs(opts.Default or{})do
selected[value]=true
end
elseif opts.Default~=nil then
selected[opts.Default]=true
end
currentValue=function()if multi then
local list={}for _,option in ipairs(options)do
if selected[option]then
table.insert(list,option)end
end
return list
end
for _,option in ipairs(options)do
if selected[option]then
return option
end
end
return nil
end
renderValueLabel=function()local value=currentValue()local isEmpty
if multi then
isEmpty=#value==0
if #value==1 then
local onlyValue=tostring(value[1])isEmpty=onlyValue:match("^%s*$")~=nil or string.lower(onlyValue)=="none"
end
fullText=isEmpty and "--" or table.concat(value,", ")else
local text=value~=nil and tostring(value)or ""
isEmpty=text:match("^%s*$")~=nil or string.lower(text)=="none"
fullText=isEmpty and "--" or text
end
valueLabel.Text=trimmed()valueLabel.TextColor3=isEmpty and Theme.Muted or Theme.Text:Lerp(Theme.Muted,0.4)for option,button in pairs(optionButtons)do
local on=selected[option]==true
if button.On~=on then
button.On=on
tween(button.Label,{TextColor3=on and Theme.Text or Theme.Muted},0.10,Enum.EasingStyle.Quint)tween(button.Label,{Position=UDim2.fromOffset(on and 22 or 13,-1),Size=UDim2.new(1,on and-47 or-38,1,0),},0.12,Enum.EasingStyle.Quint)tween(button.Check,{ImageTransparency=on and 0 or 1},0.10,Enum.EasingStyle.Quint)tween(button.CheckScale,{Scale=on and 1 or 0.82},0.12,Enum.EasingStyle.Quint)tween(button.SelectionBar,{BackgroundTransparency=on and 0 or 1},0.10,Enum.EasingStyle.Quint)end
end
end
local function visibleCount()local count=0
for _,option in ipairs(options)do
if matches(option)then
count+=1
end
end
return count
end
local function applyFilter()for option,button in pairs(optionButtons)do
button.Frame.Visible=matches(option)end
end
local function popupHeight()local rows=math.clamp(visibleCount(),1,6)local actionsHeight=showSelectAll and(SELECT_ACTION_HEIGHT+SELECT_ACTION_GAP)or 0
local contentHeight=10+SEARCH_HEIGHT+8+rows*DROPDOWN_OPTION_HEIGHT+math.max(0,rows-1)*OPTION_GAP+actionsHeight+10
return math.clamp(contentHeight,POPUP_MIN_HEIGHT,POPUP_MAX_HEIGHT)end
local function popupWidth()local camera=workspace.CurrentCamera
local viewport=camera and camera.ViewportSize or Vector2.new(1920,1080)local screenAvailable=math.max(1,viewport.X-16)if stacked then
return math.min(math.max(chip.AbsoluteSize.X,1),screenAvailable)end
local available=math.min(frame.AbsoluteSize.X,screenAvailable)local target=available*(TOUCH and 0.60 or 0.48)local upper=math.min(POPUP_MAX_WIDTH,screenAvailable)local lower=math.min(POPUP_MIN_WIDTH,upper)return math.clamp(target,lower,upper)end
local popupAnimating=false
local popupAnimationToken=0
local popupContent=nil
local scrollHosts={}local lastCanvasPositions={}local function dropdownPointInside(point,object)if not object or not object.Parent then
return false
end
local pos=object.AbsolutePosition
local size=object.AbsoluteSize
return point.X>=pos.X
and point.X<=pos.X+size.X
and point.Y>=pos.Y
and point.Y<=pos.Y+size.Y
end
local popupSide="below"
local lastPopupLocalPosition=nil
local lastPopupLocalSize=nil
local function positionPopup()if not popup.Parent then
return
end
local camera=workspace.CurrentCamera
local viewport=camera and camera.ViewportSize or Vector2.new(1920,1080)local uiScale=math.max(window.Scale.Scale,0.001)local screenWidth=popupWidth()local desiredScreenHeight=popupHeight()*uiScale
local screenHeight=desiredScreenHeight
local cardPos=frame.AbsolutePosition
local cardSize=frame.AbsoluteSize
local chipPos=chip.AbsolutePosition
local chipSize=chip.AbsoluteSize
local cardTop=chipPos.Y
local cardBottom=chipPos.Y+chipSize.Y
local cardRight=stacked and(chipPos.X+chipSize.X)or(cardPos.X+cardSize.X)local screenMargin=8
local gap=1
local belowY=cardBottom+gap
local aboveY=cardTop-screenHeight-gap
local spaceBelow=math.max(0,viewport.Y-screenMargin-belowY)local spaceAbove=math.max(0,cardTop-gap-screenMargin)local canFitBelow=spaceBelow>=desiredScreenHeight
local canFitAbove=spaceAbove>=desiredScreenHeight
if popupSide=="below" then
if not canFitBelow and canFitAbove and spaceAbove>spaceBelow+6 then
popupSide="above"
end
else
if not canFitAbove and canFitBelow and spaceBelow>spaceAbove+6 then
popupSide="below"
end
end
if not canFitBelow and canFitAbove then
popupSide="above"
elseif not canFitAbove and canFitBelow then
popupSide="below"
elseif not canFitAbove and not canFitBelow then
popupSide=spaceAbove>spaceBelow and "above" or "below"
end
local availableHeight=popupSide=="above" and spaceAbove or spaceBelow
screenHeight=math.min(desiredScreenHeight,availableHeight)local yScreen=popupSide=="above" and(cardTop-gap-screenHeight)or belowY
yScreen=math.clamp(yScreen,screenMargin,math.max(screenMargin,viewport.Y-screenHeight-screenMargin))local xScreen=cardRight-screenWidth
xScreen=math.clamp(xScreen,screenMargin,math.max(screenMargin,viewport.X-screenWidth-screenMargin))local rootPos=window.Root.AbsolutePosition
local localX=(xScreen-rootPos.X)/uiScale
local localY=(yScreen-rootPos.Y)/uiScale
local localWidth=screenWidth/uiScale
local localHeight=screenHeight/uiScale
local positionChanged=not lastPopupLocalPosition
or math.abs(lastPopupLocalPosition.X-localX)>0.05
or math.abs(lastPopupLocalPosition.Y-localY)>0.05
local sizeChanged=not lastPopupLocalSize
or math.abs(lastPopupLocalSize.X-localWidth)>0.05
or math.abs(lastPopupLocalSize.Y-localHeight)>0.05
if positionChanged then
popup.Position=UDim2.fromOffset(localX,localY)popupShadow.Position=UDim2.fromOffset(localX-16,localY-16)lastPopupLocalPosition=Vector2.new(localX,localY)end
if sizeChanged then
popup.Size=UDim2.fromOffset(localWidth,localHeight)popupShadow.Size=UDim2.fromOffset(localWidth+32,localHeight+32)lastPopupLocalSize=Vector2.new(localWidth,localHeight)end
end
setOpen=function(open)if open==self_.Open then
if open then
positionPopup()end
return
end
if open then
local previous=window._openDropdown
if previous and previous~=self_ and previous.SetOpen then
previous:SetOpen(false)end
window._openDropdown=self_
elseif window._openDropdown==self_ then
window._openDropdown=nil
end
self_.Open=open
popupAnimationToken+=1
local animationToken=popupAnimationToken
if open then
filter=""
searchBox.Text=""
applyFilter()popupSide="below"
lastPopupLocalPosition=nil
lastPopupLocalSize=nil
for _,scrollHost in ipairs(scrollHosts)do
lastCanvasPositions[scrollHost]=scrollHost.CanvasPosition
end
positionPopup()local targetPosition=popup.Position
local targetSize=popup.Size
local collapsedHeight=math.max(42,targetSize.Y.Offset-4)popup.Visible=true
popupShadow.Visible=true
popupAnimating=true
popup.Position=UDim2.fromOffset(targetPosition.X.Offset,targetPosition.Y.Offset+3)popup.Size=UDim2.fromOffset(targetSize.X.Offset,collapsedHeight)popup.BackgroundTransparency=0
popupStroke.Transparency=1
popupInnerStroke.Transparency=1
popupShadow.ImageTransparency=1
if popupContent then
popupContent.GroupTransparency=1
end
arrow:Set(true)tween(chipStroke,{Color=Theme.StrokeHover,Transparency=0.08},0.20,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)local openTween=tween(popup,{Position=targetPosition,Size=targetSize,},0.26,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)tween(popupStroke,{Transparency=1},0.24,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)tween(popupInnerStroke,{Transparency=1},0.24,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)tween(popupShadow,{ImageTransparency=0.50},0.28,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)if popupContent then
task.delay(0.035,function()if self_.Open and popupAnimationToken==animationToken and not self_._destroyed and popupContent.Parent then
tween(popupContent,{GroupTransparency=0},0.22,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)end
end)end
if openTween then
openTween.Completed:Connect(function()if self_.Open and popupAnimationToken==animationToken then
popupAnimating=false
end
end)else
popupAnimating=false
end
else
arrow:Set(false)tween(chipStroke,{Color=Theme.Stroke,Transparency=0.18},0.20,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)popupAnimating=true
local currentPosition=popup.Position
local currentSize=popup.Size
local closePosition=UDim2.fromOffset(currentPosition.X.Offset,currentPosition.Y.Offset+2)local closeSize=UDim2.fromOffset(currentSize.X.Offset,math.max(36,currentSize.Y.Offset-3))if popupContent then
tween(popupContent,{GroupTransparency=1},0.17,Enum.EasingStyle.Sine,Enum.EasingDirection.In)end
local closeTween=tween(popup,{Position=closePosition,Size=closeSize,},0.22,Enum.EasingStyle.Sine,Enum.EasingDirection.In)tween(popupStroke,{Transparency=1},0.20,Enum.EasingStyle.Sine,Enum.EasingDirection.In)tween(popupInnerStroke,{Transparency=1},0.20,Enum.EasingStyle.Sine,Enum.EasingDirection.In)tween(popupShadow,{ImageTransparency=1},0.22,Enum.EasingStyle.Sine,Enum.EasingDirection.In)local function finishClose()if popupAnimationToken~=animationToken then
return
end
popupAnimating=false
if not self_.Open and popup.Parent then
popup.Visible=false
popupShadow.Visible=false
positionPopup()end
end
if closeTween then
closeTween.Completed:Connect(finishClose)else
finishClose()end
end
end
local function buildOptions()local keep={}for index,option in ipairs(options)do
keep[option]=index
end
for option,button in pairs(optionButtons)do
if not keep[option]then
button.Frame:Destroy()optionButtons[option]=nil
end
end
for index,option in ipairs(options)do
local existing=optionButtons[option]if existing then
existing.Frame.LayoutOrder=index
continue
end
local button=create("TextButton",{Size=UDim2.new(1,0,0,DROPDOWN_OPTION_HEIGHT),BackgroundColor3=Color3.fromRGB(63,42,76),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=index,ZIndex=1002,Parent=optionScroller,})local check=create("ImageLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(15,15),BackgroundTransparency=1,ImageColor3=Theme.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=1004,Parent=button,})applyIcon(check,"check")local checkScale=create("UIScale",{Scale=0.82,Parent=check})local selectionBar=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,1,0.5,0),Size=UDim2.new(0,3,0.62,0),BackgroundColor3=Theme.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1004,Parent=button,})corner(selectionBar,UDim.new(1,0))local text_=label({Position=UDim2.fromOffset(13,-1),Size=UDim2.new(1,-38,1,0),Text=tostring(option),TextSize=self._hstack and 13 or 15,TextColor3=Theme.Muted,FontFace=Fonts.Bold,ZIndex=1004,Parent=button,})button.MouseEnter:Connect(function()if not selected[option]then
tween(text_,{TextColor3=Theme.Text},0.08,Enum.EasingStyle.Quint)end
end)button.MouseLeave:Connect(function()local on=selected[option]==true
tween(text_,{TextColor3=on and Theme.Text or Theme.Muted},0.10,Enum.EasingStyle.Quint)end)button.MouseButton1Click:Connect(function()if selected[option]then
selected[option]=nil
else
if not multi then
selected={}end
selected[option]=true
end
renderValueLabel()safeCall(opts.Callback,currentValue())if not multi and selected[option]then
setOpen(false)end
end)optionButtons[option]={Frame=button,Label=text_,Check=check,CheckScale=checkScale,SelectionBar=selectionBar,On=nil}end
applyFilter()if self_.Open then
positionPopup()end
end
function self_:Set(value,silent)selected={}if multi then
for _,item in ipairs(type(value)=="table" and value or{value})do
selected[item]=true
end
elseif value~=nil then
selected[value]=true
end
renderValueLabel()flashStroke(frameStroke)if not silent then
safeCall(opts.Callback,currentValue())end
end
function self_:Get()return currentValue()end
function self_:Refresh(newOptions,keepSelection)options=newOptions or{}if not keepSelection then
selected={}end
buildOptions()renderValueLabel()end
function self_:SetOpen(open)setOpen(open==true)end
header.MouseButton1Click:Connect(function()setOpen(not self_.Open)end)searchBox:GetPropertyChangedSignal("Text"):Connect(function()filter=string.lower(searchBox.Text)applyFilter()if self_.Open then
positionPopup()end
end)local function anchorIsVisible()if not frame.Visible then
return false
end
local framePos=frame.AbsolutePosition
local frameSize=frame.AbsoluteSize
local parent=frame.Parent
while parent and parent~=self.Body do
if parent:IsA("GuiObject")and(parent.ClipsDescendants or parent:IsA("ScrollingFrame"))then
local parentPos=parent.AbsolutePosition
local parentSize=parent.AbsoluteSize
local left=math.max(framePos.X,parentPos.X)local top=math.max(framePos.Y,parentPos.Y)local right=math.min(framePos.X+frameSize.X,parentPos.X+parentSize.X)local bottom=math.min(framePos.Y+frameSize.Y,parentPos.Y+parentSize.Y)if right<=left or bottom<=top then
return false
end
end
parent=parent.Parent
end
return true
end
scrollHosts={}do
local parent=frame.Parent
while parent and parent~=self.Body do
if parent:IsA("ScrollingFrame")then
table.insert(scrollHosts,parent)end
parent=parent.Parent
end
end
lastCanvasPositions={}local scrollReanchorQueued=false
local function queueSmartReanchor()if scrollReanchorQueued then
return
end
scrollReanchorQueued=true
task.defer(function()scrollReanchorQueued=false
if self_._destroyed or window._destroyed or not self_.Open then
return
end
if not anchorIsVisible()then
setOpen(false)return
end
if not popupAnimating then
positionPopup()end
end)end
local function trackConnection(connection)table.insert(self_._listeners,function()connection:Disconnect()end)end
for _,scrollHost in ipairs(scrollHosts)do
lastCanvasPositions[scrollHost]=scrollHost.CanvasPosition
trackConnection(scrollHost:GetPropertyChangedSignal("CanvasPosition"):Connect(function()if self_._destroyed or window._destroyed or not self_.Open then
lastCanvasPositions[scrollHost]=scrollHost.CanvasPosition
return
end
local current=scrollHost.CanvasPosition
local previous=lastCanvasPositions[scrollHost]or current
local delta=current-previous
lastCanvasPositions[scrollHost]=current
if delta.Magnitude<=0 or popupAnimating then
queueSmartReanchor()return
end
local uiScale=math.max(window.Scale.Scale,0.001)local dx=-delta.X/uiScale
local dy=-delta.Y/uiScale
popup.Position=UDim2.fromOffset(popup.Position.X.Offset+dx,popup.Position.Y.Offset+dy)popupShadow.Position=UDim2.fromOffset(popupShadow.Position.X.Offset+dx,popupShadow.Position.Y.Offset+dy)if lastPopupLocalPosition then
lastPopupLocalPosition=Vector2.new(lastPopupLocalPosition.X+dx,lastPopupLocalPosition.Y+dy)end
queueSmartReanchor()end))end
trackConnection(window.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()if self_._destroyed or window._destroyed or not self_.Open or popupAnimating then
return
end
positionPopup()end))window:_listen("Began",function(input)if not self_.Open or not isPress(input)then
return
end
task.defer(function()if not self_.Open or window._destroyed then
return
end
local point=pointerPosition()if not dropdownPointInside(point,header)and not dropdownPointInside(point,popup)then
setOpen(false)end
end)end,self_)buildOptions()renderValueLabel()popupContent=create("CanvasGroup",{Name="DropdownPopoverContent",Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,GroupTransparency=0,ZIndex=1001,Parent=popup,})popupContent:SetAttribute("JinHubDropdownPopup",true)searchHolder.Parent=popupContent
optionScroller.Parent=popupContent
task.defer(fitChip,true)local element=finishElement(self,opts,self_,frame,"Dropdown")local baseDestroy=element.Destroy
function element:Destroy()if window._openDropdown==self_ then
window._openDropdown=nil
end
self_._destroyed=true
self_.Open=false
popupAnimating=false
if popup and popup.Parent then
popup.Visible=false
popup:Destroy()end
if popupShadow and popupShadow.Parent then
popupShadow.Visible=false
popupShadow:Destroy()end
baseDestroy()end
return element
end
function Tab:Input(opts)opts=normalize(opts,{Title="Name",Description="Desc",PlaceholderText="Placeholder",CurrentValue="Default",Value="Default"})local modern=opts.Modern==true
local modernHeight
if modern then
modernHeight=(opts.Desc and(TOUCH and 92 or 84)or(TOUCH and 80 or 72))-(self._flatElements and 4 or 0)end
local frame,frameStroke,_,titleLabel,descLabel
local rightReserve=160
if modern then
rightReserve=nil
end
opts,frame,frameStroke,_,titleLabel,descLabel=beginElement(self,opts,{},"Frame",rightReserve,"Input",modernHeight)local inset=frame:GetAttribute("JinHubFlatSectionElement")and 8 or 14
local inputTop=opts.Desc and 44 or 26
if modern then
titleLabel=label({Position=UDim2.fromOffset(inset,5),Size=UDim2.new(1,-(inset*2),0,18),Text=opts.Name or "Input",Parent=frame,})if opts.Desc then
descLabel=label({Position=UDim2.fromOffset(inset,23),Size=UDim2.new(1,-(inset*2),0,16),Text=opts.Desc,TextSize=13,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=frame,})end
end
local boxHolder=create("Frame",{AnchorPoint=modern and Vector2.zero or Vector2.new(1,0.5),Position=modern and UDim2.new(0,inset,0,inputTop)or UDim2.new(1,-10,0.5,0),Size=modern and UDim2.new(1,-(inset*2),0,30)or UDim2.fromOffset(170,30),BackgroundColor3=Theme.Surface,BorderSizePixel=0,Parent=frame,})corner(boxHolder,UDim.new(0,6))local boxStroke=stroke(boxHolder)local boxIcon=opts.Icon
if boxIcon then
glowIcon(boxHolder,boxIcon,Theme.Muted,UDim2.new(0,8,0.5,0))end
local box=create("TextBox",{Position=UDim2.fromOffset(boxIcon and 30 or 8,0),Size=UDim2.new(1,boxIcon and-38 or-16,1,0),BackgroundTransparency=1,Text=opts.Default or "",PlaceholderText=opts.Placeholder or "",PlaceholderColor3=Theme.Muted,TextColor3=Theme.Text,TextSize=15,FontFace=Fonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=boxHolder,})boxHolder.ClipsDescendants=true
local focused=false
local textInset=(boxIcon and 30 or 8)+8
local function fitBox(instant)if modern then
local size=UDim2.new(1,-(inset*2),0,30)if instant then
boxHolder.Size=size
else
tween(boxHolder,{Size=size},0.18)end
return
end
local cardWidth=frame.AbsoluteSize.X/self.Window.Scale.Scale
local maxWidth=math.clamp(cardWidth-14-110-20,100,200)local content=box.Text
local measured=box.TextBounds.X
if #content==0 then
measured=math.min(box.TextBounds.X,90)end
local width=math.clamp(measured+textInset+12,90,maxWidth)+(focused and 8 or 0)width=math.min(width,maxWidth+8)reserveRight(titleLabel,descLabel,width+20)if instant then
boxHolder.Size=UDim2.fromOffset(width,30)else
tween(boxHolder,{Size=UDim2.fromOffset(width,30)},0.18)end
end
frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()fitBox(true)end)box:GetPropertyChangedSignal("Text"):Connect(function()fitBox(false)end)box:GetPropertyChangedSignal("TextBounds"):Connect(function()fitBox(false)end)task.defer(fitBox,true)box.Focused:Connect(function()focused=true
tween(boxStroke,{Color=Theme.StrokeHover},0.15)fitBox(false)end)box.FocusLost:Connect(function(enterPressed)focused=false
tween(boxStroke,{Color=Theme.Stroke},0.15)fitBox(false)if opts.Numeric then
local number=tonumber(box.Text)if not number then
box.Text=""
return
end
end
safeCall(opts.Callback,box.Text,enterPressed)end)return finishElement(self,opts,{Set=function(_,value)box.Text=tostring(value)flashStroke(frameStroke)end,Get=function()return box.Text
end,},frame,"Input")end
function Tab:Keybind(opts)local frame,frameStroke,_,titleLabel,descLabel
opts,frame,frameStroke,_,titleLabel,descLabel=beginElement(self,opts,{Title="Name",Description="Desc",CurrentKeybind="Default",Value="Default"},"Frame",110,"Keybind")if type(opts.Default)=="string" then
opts.Default=Enum.KeyCode[opts.Default]end
local chip=create("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(44,CHIP_HEIGHT),BackgroundColor3=Theme.Surface,BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,Parent=frame,})corner(chip,UDim.new(0,6))local chipStroke=stroke(chip)local chipLabel=label({Size=UDim2.new(1,0,1,0),TextSize=16,TextColor3=Theme.Muted,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,Parent=chip,})local self_={Value=opts.Default,Listening=false}local function fitChip(instant)local width=math.max(chipLabel.TextBounds.X+20,TOUCH and 44 or 36)reserveRight(titleLabel,descLabel,width+20)if instant then
chip.Size=UDim2.fromOffset(width,CHIP_HEIGHT)else
tween(chip,{Size=UDim2.fromOffset(width,CHIP_HEIGHT)},0.2)end
end
chipLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()fitChip(false)end)local function render()chipLabel.Text=self_.Listening and "..." or keyName(self_.Value)tween(chipStroke,{Color=self_.Listening and Theme.StrokeHover or Theme.Stroke},0.15)tween(chipLabel,{TextColor3=self_.Listening and Theme.Accent or Theme.Muted},0.15)end
function self_:Set(keyCode,silent)local wasListening=self_.Listening
self_.Value=keyCode
self_.Listening=false
render()if not wasListening then
flashStroke(frameStroke)end
if not silent then
safeCall(opts.OnChanged,keyCode)end
end
chip.MouseButton1Click:Connect(function()self_.Listening=not self_.Listening
render()end)self.Window:_listen("Began",function(input,gameProcessed)if input.UserInputType~=Enum.UserInputType.Keyboard then
return
end
if self_.Listening then
self.Window._consumedKey=input.KeyCode
self.Window._consumedAt=os.clock()if input.KeyCode==Enum.KeyCode.Escape then
self_.Listening=false
render()else
self_:Set(input.KeyCode)end
return
end
if not gameProcessed and self_.Value~=nil and input.KeyCode==self_.Value then
safeCall(opts.Callback,input.KeyCode)end
end,self_)render()task.defer(fitChip,true)function self_:Get()return self_.Value
end
return finishElement(self,opts,self_,frame,"Keybind")end
function Tab:ColorPicker(opts)local PANEL_HEIGHT=168
local frame,frameStroke,height
opts,frame,frameStroke,height=beginElement(self,opts,{Title="Name",Description="Desc",Color="Default",CurrentValue="Default",Value="Default"},"Frame")frame.ClipsDescendants=true
local header=create("TextButton",{Size=UDim2.new(1,0,0,height),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=frame,})titleDesc(header,opts.Name or "Color",opts.Desc,90)local swatch=create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-34,0.5,0),Size=UDim2.fromOffset(36,20),BorderSizePixel=0,Parent=header,})corner(swatch,UDim.new(0,6))stroke(swatch,Theme.Stroke)local arrow=arrowIndicator(header,1,-12)local panel=create("Frame",{Position=UDim2.fromOffset(14,height+2),Size=UDim2.new(1,-28,0,PANEL_HEIGHT-12),BackgroundTransparency=1,Visible=false,Parent=frame,})local svBox=create("TextButton",{Size=UDim2.new(1,-30,0,110),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,Parent=panel,})corner(svBox,UDim.new(0,6))local svHueGradient=create("UIGradient",{Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,0,0)),Parent=svBox,})local svDark=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=svBox,})create("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0),}),Rotation=90,Parent=svDark,})local svCursor=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1,ZIndex=3,Parent=svBox,})corner(svCursor,UDim.new(1,0))stroke(svCursor,Color3.new(1,1,1),0,2)local hueBar=create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(14,110),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=panel,})corner(hueBar,UDim.new(0,6))create("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(1/6,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(2/6,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(3/6,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(4/6,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(5/6,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0)),}),Rotation=90,Parent=hueBar,})local hueCursor=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0,0),Size=UDim2.fromOffset(18,5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=3,Parent=hueBar,})corner(hueCursor,UDim.new(1,0))stroke(hueCursor,Theme.AccentDark,0.4)local hexHolder=create("Frame",{Position=UDim2.fromOffset(6,122),Size=UDim2.fromOffset(118,28),BackgroundColor3=Theme.Surface,BorderSizePixel=0,Parent=panel,})corner(hexHolder,UDim.new(0,6))local hexStroke=stroke(hexHolder)local hexBox=create("TextBox",{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text="",TextTruncate=Enum.TextTruncate.None,ClipsDescendants=false,TextColor3=Theme.Text,TextSize=16,FontFace=Fonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=hexHolder,})local rgbLabel=label({Position=UDim2.fromOffset(134,122),Size=UDim2.new(1,-134,0,28),TextXAlignment=Enum.TextXAlignment.Right,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=panel,})local self_={Open=false}local hue,sat,val=Color3.toHSV(opts.Default or Theme.Accent)local dragTarget=nil
local function toHex(color)return string.format("#%02X%02X%02X",math.floor(color.R*255+0.5),math.floor(color.G*255+0.5),math.floor(color.B*255+0.5))end
local function render(duration)local color=Color3.fromHSV(hue,sat,val)self_.Value=color
swatch.BackgroundColor3=color
svHueGradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromHSV(hue,1,1))tween(svCursor,{Position=UDim2.fromScale(sat,1-val)},duration,Enum.EasingStyle.Linear)tween(hueCursor,{Position=UDim2.new(0.5,0,hue,0)},duration,Enum.EasingStyle.Linear)if not hexBox:IsFocused()then
hexBox.Text=toHex(color)end
rgbLabel.Text=string.format("RGB %d, %d, %d",math.floor(color.R*255+0.5),math.floor(color.G*255+0.5),math.floor(color.B*255+0.5))end
local function commit(duration,silent)render(duration)if not silent then
safeCall(opts.Callback,self_.Value)end
end
function self_:Set(color,silent)hue,sat,val=Color3.toHSV(color)commit(0.25,silent)flashStroke(frameStroke)end
function self_:Get()return self_.Value
end
local function setOpen(open)self_.Open=open
tween(frame,{Size=UDim2.new(1,0,0,open and(height+PANEL_HEIGHT)or height)},0.35,Enum.EasingStyle.Quint)arrow:Set(open)if open then
panel.Visible=true
else
task.delay(0.35,function()if not self_.Open then
panel.Visible=false
end
end)end
end
function self_:SetOpen(open)setOpen(open==true)end
header.MouseButton1Click:Connect(function()setOpen(not self_.Open)end)local function updateSV(position)sat=math.clamp((position.X-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X,0,1)val=1-math.clamp((position.Y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y,0,1)commit(0.04)end
local function updateHue(position)hue=math.clamp((position.Y-hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y,0,0.999)commit(0.04)end
svBox.InputBegan:Connect(function(input)if isPress(input)then
dragTarget="sv"
tween(svCursor,{Size=UDim2.fromOffset(14,14)},0.15,Enum.EasingStyle.Back)updateSV(pointerPosition())end
end)hueBar.InputBegan:Connect(function(input)if isPress(input)then
dragTarget="hue"
tween(hueCursor,{Size=UDim2.fromOffset(20,7)},0.15,Enum.EasingStyle.Back)updateHue(pointerPosition())end
end)self.Window:_listen("Changed",function(input)if not dragTarget or not isMove(input)then
return
end
local position=pointerPosition()if dragTarget=="sv" then
updateSV(position)else
updateHue(position)end
end,self_)self.Window:_listen("Ended",function(input)if dragTarget and isPress(input)then
dragTarget=nil
tween(svCursor,{Size=UDim2.fromOffset(10,10)},0.2)tween(hueCursor,{Size=UDim2.fromOffset(18,5)},0.2)end
end,self_)hexBox.Focused:Connect(function()tween(hexStroke,{Color=Theme.StrokeHover},0.15)end)hexBox.FocusLost:Connect(function()tween(hexStroke,{Color=Theme.Stroke},0.15)local r,g,b=hexBox.Text:match("^%s*#?(%x%x)(%x%x)(%x%x)%s*$")if r then
self_:Set(Color3.fromRGB(tonumber(r,16),tonumber(g,16),tonumber(b,16)))else
hexBox.Text=toHex(self_.Value)end
end)render(0)return finishElement(self,opts,self_,frame,"ColorPicker")end
function Tab:Stepper(opts)local frame,frameStroke,_,titleLabel,descLabel
opts,frame,frameStroke,_,titleLabel,descLabel=beginElement(self,opts,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default",Increment="Step"},"Frame",150,"Stepper")local min=opts.Min or 0
local max=opts.Max or 100
local step=opts.Step or 1
local suffix=opts.Suffix or ""
local numbers=numberFormat(min,max,step)local group=create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(0,CHIP_HEIGHT),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=Theme.Surface,BorderSizePixel=0,Parent=frame,})corner(group,UDim.new(0,6))local groupStroke=stroke(group)create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=group,})local function stepButton(text,order)local button=create("TextButton",{Size=UDim2.fromOffset(CHIP_HEIGHT,CHIP_HEIGHT),BackgroundTransparency=1,Text=text,TextColor3=Theme.Muted,TextSize=19,FontFace=Fonts.Medium,AutoButtonColor=false,LayoutOrder=order,Parent=group,})button.MouseEnter:Connect(function()tween(button,{TextColor3=Theme.Accent},0.12)end)button.MouseLeave:Connect(function()tween(button,{TextColor3=Theme.Muted},0.2)end)return button
end
local minus=stepButton("−",1)local valueLabel=label({Size=UDim2.new(0,30,1,0),TextSize=16,TextColor3=Theme.Accent,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,LayoutOrder=2,Parent=group,})local plus=stepButton("+",3)local function fitValue(instant)local width=math.max(valueLabel.TextBounds.X+12,30)if instant then
valueLabel.Size=UDim2.new(0,width,1,0)else
tween(valueLabel,{Size=UDim2.new(0,width,1,0)},0.2)end
end
valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()fitValue(false)end)group:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()reserveRight(titleLabel,descLabel,group.AbsoluteSize.X/self.Window.Scale.Scale+20)end)local self_={Value=math.clamp(opts.Default or min,min,max)}local snap=numbers.snap
local fromButton=false
local function render()valueLabel.Text=numbers.format(self_.Value)..suffix
tween(minus,{TextTransparency=self_.Value<=min and 0.6 or 0},0.15)tween(plus,{TextTransparency=self_.Value>=max and 0.6 or 0},0.15)end
function self_:Set(value,silent)value=snap(tonumber(value)or min)if value==self_.Value then
return
end
self_.Value=value
render()if not fromButton then
flashStroke(frameStroke)end
if not silent then
safeCall(opts.Callback,value)end
end
function self_:Get()return self_.Value
end
local function bump(direction)fromButton=true
self_:Set(self_.Value+direction*step)fromButton=false
tween(groupStroke,{Color=Theme.StrokeHover},0.08)task.delay(0.12,function()tween(groupStroke,{Color=Theme.Stroke},0.2)end)end
local function holdRepeat(button,direction)local holding=false
button.InputBegan:Connect(function(input)if not isPress(input)then
return
end
holding=true
bump(direction)task.delay(0.4,function()while holding do
bump(direction)task.wait(0.07)end
end)end)button.InputEnded:Connect(function(input)if isPress(input)then
holding=false
end
end)button.MouseLeave:Connect(function()holding=false
end)end
holdRepeat(minus,-1)holdRepeat(plus,1)render()task.defer(fitValue,true)return finishElement(self,opts,self_,frame,"Stepper")end
function Tab:Progress(opts)opts=normalize(opts,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default"})local frame,frameStroke=card(self,"Frame",opts.Desc and CARD_HEIGHT_DESC+10 or CARD_HEIGHT+10,opts)hoverStroke(frame,frameStroke)local top=opts.Desc and(CARD_HEIGHT_DESC-38)/2-2 or 12
label({Position=UDim2.fromOffset(14,top),Size=UDim2.new(1,-110,0,18),Text=opts.Name or "Progress",Parent=frame,})if opts.Desc then
label({Position=UDim2.fromOffset(14,top+20),Size=UDim2.new(1,-110,0,17),Text=opts.Desc,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=frame,})end
local valueLabel=label({AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,top),Size=UDim2.fromOffset(90,18),TextXAlignment=Enum.TextXAlignment.Right,TextSize=16,TextColor3=Theme.Accent,Parent=frame,})local track=create("Frame",{Position=UDim2.new(0,14,1,-16),Size=UDim2.new(1,-28,0,5),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,Parent=frame,})corner(track,UDim.new(1,0))local fill=create("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=opts.Color or Theme.Accent,BorderSizePixel=0,Parent=track,})corner(fill,UDim.new(1,0))local self_={Value=math.clamp(opts.Default or 0,0,1)}local formatter=opts.Format
local function render(duration)local frac=self_.Value
tween(fill,{Size=UDim2.new(frac,0,1,0)},duration,Enum.EasingStyle.Quint)if type(formatter)=="function" then
valueLabel.Text=tostring(formatter(frac))else
valueLabel.Text=string.format("%d%%",math.floor(frac*100+0.5))end
end
function self_:Set(value,silent)value=math.clamp(tonumber(value)or 0,0,1)if value==self_.Value then
return
end
self_.Value=value
render(0.35)if not silent then
safeCall(opts.Callback,value)end
end
function self_:Get()return self_.Value
end
function self_:SetColor(color)fill.BackgroundColor3=color
end
render(0)return finishElement(self,opts,self_,frame,"Progress")end
function Tab:ConfigManager(opts)opts=normalize(opts,{})local window=self.Window
local manager={}self:Section(opts.Name or "Configs")local nameInput=self:Input({Name="Config name",Placeholder=window.ConfigName,Callback=function(text,enterPressed)if enterPressed and #text>0 then
manager:Save(text)end
end,})local list=self:Dropdown({Name="Saved configs",Options=window:ListConfigs(),Default=window.ConfigName,Callback=function(choice)if choice then
nameInput:Set(choice)end
end,})function manager:Refresh()list:Refresh(window:ListConfigs(),true)end
function manager:Save(name)name=name or list:Get()or window.ConfigName
local ok,err=window:SaveConfig(name)manager:Refresh()list:Set(name,true)window:Notify({Title=ok and "Config saved" or "Save failed",Content=ok and name or tostring(err),Type=ok and "Success" or "Error",Duration=3})end
function manager:Load(name)name=name or list:Get()if not name then
return
end
local ok,err=window:LoadConfig(name)window:Notify({Title=ok and "Config loaded" or "Load failed",Content=ok and name or tostring(err),Type=ok and "Success" or "Error",Duration=3})end
function manager:Delete(name)name=name or list:Get()if not name then
return
end
local ok,err=window:DeleteConfig(name)manager:Refresh()window:Notify({Title=ok and "Config deleted" or "Delete failed",Content=ok and name or tostring(err),Type=ok and "Info" or "Error",Duration=3})end
self:Button({Name="Save",Desc="Writes every flagged element to the selected name",Icon="save",Style="Primary",Callback=function()local typed=nameInput:Get()manager:Save(#typed>0 and typed or nil)end})self:Button({Name="Load",Icon="folder-open",Callback=function()manager:Load()end})self:Button({Name="Delete",Icon="trash-2",Callback=function()local name=list:Get()if not name then
return
end
window:Confirm({Title="Delete config",Content="Remove "..name.."? This cannot be undone.",Icon="trash-2",ConfirmText="Delete",Callback=function()manager:Delete(name)end,})end})self:Toggle({Name="Auto save",Desc="Save whenever a flagged element changes",Default=window._autoSaveEnabled,Callback=function(on)window._autoSaveEnabled=on
end,})return manager
end
for name,method in pairs(table.clone(Tab))do
if type(method)=="function" and name:sub(1,1)~="_" and name:sub(1,6)~="Create" then
Tab["Create"..name]=method
end
end
local function detectExecutor()local name
pcall(function()if typeof(identifyexecutor)=="function" then
name=(identifyexecutor())elseif typeof(getexecutorname)=="function" then
name=getexecutorname()end
end)if type(name)=="string" and #name>0 then
return name
end
return RunService:IsStudio()and "Studio" or "Unknown"
end
local function detectGameName()local ok,info=pcall(function()return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)end)if ok and type(info)=="table" and info.Name then
return info.Name
end
return "Unknown game"
end
local REGION_NAMES={US="United States",GB="United Kingdom",DE="Germany",FR="France",NL="Netherlands",SG="Singapore",JP="Japan",AU="Australia",BR="Brazil",IN="India",HK="Hong Kong",CA="Canada",}local function detectRegion(callback)task.spawn(function()local requester=request or http_request or(syn and syn.request)or(http and http.request)local region
if type(requester)=="function" then
pcall(function()local response=requester({Url="https://ipinfo.io/json",Method="GET"})local body=type(response)=="table" and(response.Body or response.body)or nil
if type(body)=="string" then
local data=HttpService:JSONDecode(body)if type(data)=="table" and data.country then
local label=REGION_NAMES[data.country]or data.country
region=data.city and(data.city..", "..label)or label
end
end
end)end
callback(region or "Unavailable")end)end
local NOTIFY_COLORS={Success=Theme.Success,Warning=Theme.Warning,Error=Theme.Error,}local Window={}Window.__index=Window
function Library.Window(_,opts)opts=normalize(opts,{Name="Title",LoadingSubtitle="Subtitle",ToggleUIKeybind="Keybind"})local guiName=opts.Name or "JinHubxUI"
local guiParent=opts.Parent or defaultParent()local persistentRegistry=getPersistentWindowRegistry()local previousEntry=persistentRegistry and persistentRegistry[guiName]if previousEntry and previousEntry.Owner~=Library and previousEntry.Window
and not previousEntry.Window._destroyed then
pcall(function()previousEntry.Window:Destroy()end)end
if #Library.Windows==0 and guiParent then
pcall(function()for _,child in ipairs(guiParent:GetChildren())do
if child:IsA("ScreenGui")then
local isCurrentWindow=child.Name==guiName
local root=child:FindFirstChild("Window")local body=root and root:FindFirstChild("Body")local sidebar=body and body:FindFirstChild("Sidebar")local header=sidebar and sidebar:FindFirstChild("Header")local isPreviousLibraryWindow=root and root:IsA("Frame")and body and body:IsA("GuiObject")and sidebar and sidebar:IsA("Frame")and header and header:IsA("Frame")local isRegisteredWindow=previousEntry and previousEntry.Window
and child==previousEntry.Window.Gui
if(isCurrentWindow or isPreviousLibraryWindow)and not isRegisteredWindow then
child:Destroy()end
end
end
end)end
if type(opts.Keybind)=="string" then
opts.Keybind=Enum.KeyCode[opts.Keybind]end
local size=opts.Size or UDim2.fromOffset(640,480)local keybind=opts.Keybind or Enum.KeyCode.RightControl
local mobileScale=type(opts.MobileScale)=="number" and opts.MobileScale or 0.55
mobileScale=math.clamp(mobileScale,0.35,1)local self=setmetatable({Tabs={},_sidebarOrder=0,CurrentTab=nil,Open=true,Keybind=keybind,NewElements=opts.NewElements==true,MobileScale=mobileScale,_connections={},_controls={},_elements={},_inputListeners={Began={},Changed={},Ended={},Render={}},_frameSteps={},_destroyed=false,_persistentRegistry=persistentRegistry,_registryName=guiName,},Window)if persistentRegistry then
persistentRegistry[guiName]={Owner=Library,Window=self}end
local function dispatch(kind)return function(...)for _,handler in ipairs(self._inputListeners[kind])do
handler(...)end
end
end
local renderDispatch=dispatch("Render")table.insert(self._connections,RunService.RenderStepped:Connect(function(deltaTime)renderDispatch(deltaTime)for _,step in ipairs(self._frameSteps)do
step(deltaTime)end
end))table.insert(self._connections,UserInputService.InputBegan:Connect(dispatch("Began")))table.insert(self._connections,UserInputService.InputChanged:Connect(dispatch("Changed")))table.insert(self._connections,UserInputService.InputEnded:Connect(dispatch("Ended")))local gui=create("ScreenGui",{Name=guiName,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,})self.Gui=gui
local root=create("Frame",{Name="Window",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=size,BackgroundTransparency=1,Parent=gui,})self.Root=root
local scale=create("UIScale",{Parent=root})self.Scale=scale
local shadow=create("ImageLabel",{Position=UDim2.fromOffset(-25,-25),Size=UDim2.new(1,50,1,50),BackgroundTransparency=1,Image=Assets.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=0.6,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),Parent=root,})self.Shadow=shadow
local body=create("CanvasGroup",{Name="Body",Size=UDim2.fromScale(1,1),BackgroundColor3=Theme.Background,BorderSizePixel=0,Parent=root,})self.Body=body
corner(body,UDim.new(0,10))self.BodyStroke=stroke(body,Theme.Stroke)edgeHighlight(body)glow(body,UDim2.fromOffset(500,180),UDim2.new(0.5,0,1,8),0.86,270)glow(body,UDim2.fromOffset(130,60),UDim2.new(0,-10,1,-10),0.75,90)glow(body,UDim2.fromOffset(520,240),UDim2.new(1,-14,0,10),0.92,90)local sidebar=create("Frame",{Name="Sidebar",Size=UDim2.new(0,SIDEBAR_WIDTH,1,0),BackgroundTransparency=1,Parent=body,})create("Frame",{Position=UDim2.new(0,SIDEBAR_WIDTH,0,28),Size=UDim2.new(0,1,1,-28),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,Parent=body,})local header=create("Frame",{Name="Header",Size=UDim2.new(1,0,0,HEADER_HEIGHT),BackgroundTransparency=1,Parent=sidebar,})local logo=create("ImageLabel",{Position=UDim2.fromOffset(22,27),Size=UDim2.fromOffset(30,28),BackgroundTransparency=1,Image="",ImageColor3=Theme.Accent,ScaleType=Enum.ScaleType.Fit,Parent=header,})applyIcon(logo,opts.Icon or Assets.Logo)label({Position=UDim2.fromOffset(60,25),Size=UDim2.new(1,-70,0,20),Text=opts.Title or "JinHub",TextSize=21,Parent=header,})label({Position=UDim2.fromOffset(60,45),Size=UDim2.new(1,-70,0,14),Text=opts.Subtitle or "",TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=header,})local tabList=create("ScrollingFrame",{Name="Tabs",Position=UDim2.fromOffset(0,HEADER_HEIGHT+8),Size=UDim2.new(1,0,1,-(HEADER_HEIGHT+8+36)),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=sidebar,})self.TabList=tabList
padding(tabList,16,16,4,4)create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=tabList,})local indicator=create("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromOffset(6,0),Size=UDim2.fromOffset(3,18),BackgroundColor3=Theme.Accent,BorderSizePixel=0,Visible=false,ZIndex=2,Parent=sidebar,})corner(indicator,UDim.new(1,0))self.Indicator=indicator
local lastCanvasY=tabList.CanvasPosition.Y
table.insert(self._frameSteps,function()local canvasY=tabList.CanvasPosition.Y
if canvasY==lastCanvasY or not self.CurrentTab or not self._introDone then
return
end
lastCanvasY=canvasY
local targetY=self:_indicatorY(self.CurrentTab)local top=tabList.Position.Y.Offset
local bottom=top+tabList.AbsoluteSize.Y/self.Scale.Scale
indicator.Visible=targetY>top and targetY<bottom
indicator.Position=UDim2.fromOffset(6,targetY)end)local statusBar=create("Frame",{Name="StatusBar",Position=UDim2.new(0,SIDEBAR_WIDTH+1,1,-28),Size=UDim2.new(1,-(SIDEBAR_WIDTH+1),0,28),BackgroundColor3=Theme.Background,BackgroundTransparency=0.45,BorderSizePixel=0,ZIndex=5,Parent=body,})create("Frame",{Name="StatusBarDivider",Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,ZIndex=5,Parent=statusBar,})self.StatusBar=statusBar
local gameNameLabel=label({AnchorPoint=Vector2.new(0.5,0),Size=UDim2.fromScale(1,1),Text="Loading...",TextSize=16,TextColor3=Theme.Muted,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=6,Parent=statusBar,})self.GameNameLabel=gameNameLabel
self._placeGameNameLabel=function(tagWidth)local reserve=(tagWidth or 0)+((tagWidth or 0)>0 and 20 or 0)gameNameLabel.Position=UDim2.new(0.5,-reserve/2,0,0)gameNameLabel.Size=UDim2.new(1,-reserve,1,0)end
task.spawn(function()gameNameLabel.Text=detectGameName()end)local footer=create("Frame",{Position=UDim2.new(0,22,1,-36),Size=UDim2.new(1,-44,0,22),BackgroundTransparency=1,ZIndex=6,Parent=sidebar,})local keyChip=create("Frame",{Size=UDim2.fromOffset(0,22),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=6,Parent=footer,})corner(keyChip,UDim.new(0,5))stroke(keyChip)padding(keyChip,7,7)local keyChipLabel=label({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=keyName(keybind),TextSize=12,TextColor3=Theme.Muted,TextTruncate=Enum.TextTruncate.None,ZIndex=6,Parent=keyChip,})self._keyChipLabel=keyChipLabel
local hintLabel=label({Size=UDim2.new(1,0,1,0),Text=TOUCH and "or tap the pill" or "to hide",TextSize=13,FontFace=Fonts.Regular,TextColor3=Theme.Muted,ZIndex=6,Parent=footer,})local function placeHint()hintLabel.Position=UDim2.fromOffset(keyChip.AbsoluteSize.X/self.Scale.Scale+8,0)end
keyChip:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeHint)task.defer(placeHint)local content=create("Frame",{Name="Content",Position=UDim2.fromOffset(SIDEBAR_WIDTH+1,0),Size=UDim2.new(1,-(SIDEBAR_WIDTH+1),1,-28),BackgroundTransparency=1,ClipsDescendants=true,Parent=body,})self.Content=content
self._outLayer=create("CanvasGroup",{Name="TransitionOut",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=2,Parent=content,})self._inLayer=create("CanvasGroup",{Name="TransitionIn",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=3,Parent=content,})local closeButton=create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,14),Size=UDim2.fromOffset(34,34),BackgroundColor3=Theme.Surface2,BackgroundTransparency=1,Text="×",TextColor3=Theme.Muted,TextSize=29,FontFace=Fonts.Bold,AutoButtonColor=false,ZIndex=5,Parent=content,})padding(closeButton,0,0,1,0)corner(closeButton,UDim.new(0,8))closeButton.MouseEnter:Connect(function()tween(closeButton,{BackgroundTransparency=0,TextColor3=Theme.Text},0.15)end)closeButton.MouseLeave:Connect(function()tween(closeButton,{BackgroundTransparency=1,TextColor3=Theme.Muted},0.2)end)closeButton.MouseButton1Click:Connect(function()self:Destroy()end)local function makeWindowControl(iconName,rightOffset)local control=create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-rightOffset,0,14),Size=UDim2.fromOffset(34,34),BackgroundColor3=Theme.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=5,Parent=content,})corner(control,UDim.new(0,8))local image=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=Theme.Muted,ScaleType=Enum.ScaleType.Fit,ZIndex=6,Parent=control,})applyIcon(image,iconName)control.MouseEnter:Connect(function()tween(control,{BackgroundTransparency=0},0.15)tween(image,{ImageColor3=Theme.Text},0.15)end)control.MouseLeave:Connect(function()tween(control,{BackgroundTransparency=1},0.2)tween(image,{ImageColor3=Theme.Muted},0.2)end)return control
end
local searchButton=makeWindowControl("search",88)local minimizeButton=makeWindowControl("minus",50)minimizeButton.MouseButton1Click:Connect(function()self:Toggle(false)end)local searchField=create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-88,0,14),Size=UDim2.fromOffset(34,34),BackgroundColor3=Theme.Surface,BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=6,Parent=content,})corner(searchField,UDim.new(0,8))local searchFieldStroke=stroke(searchField,Theme.Stroke,1)local searchIcon=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=Theme.Muted,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=7,Parent=searchField,})applyIcon(searchIcon,"search")local searchInput=create("TextBox",{Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-42,1,0),BackgroundTransparency=1,Text="",TextTransparency=1,PlaceholderText="Search tabs...",PlaceholderColor3=Theme.Muted,TextColor3=Theme.Text,TextSize=16,FontFace=Fonts.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=7,Parent=searchField,})local function filterTabs(query)query=string.lower(query or "")local firstMatch
for _,candidate in ipairs(self.Tabs)do
local matches=query=="" or string.find(string.lower(candidate.Name),query,1,true)~=nil
candidate._button.Visible=matches
if matches and not firstMatch then
firstMatch=candidate
end
end
if self.CurrentTab and not self.CurrentTab._button.Visible and firstMatch then
self:SelectTab(firstMatch)end
end
searchInput:GetPropertyChangedSignal("Text"):Connect(function()filterTabs(searchInput.Text)end)local searchAnimationToken=0
local searchClosing=false
local function closeSearch()if searchClosing then
return
end
searchClosing=true
searchAnimationToken+=1
local token=searchAnimationToken
if searchInput:IsFocused()then
searchInput:ReleaseFocus()end
tween(searchField,{Size=UDim2.fromOffset(34,34),BackgroundTransparency=1,},0.16,Enum.EasingStyle.Quart,Enum.EasingDirection.In)tween(searchFieldStroke,{Transparency=1},0.12)tween(searchIcon,{ImageTransparency=1},0.1)tween(searchInput,{TextTransparency=1},0.1)task.delay(0.17,function()if searchAnimationToken==token then
searchField.Visible=false
searchButton.Visible=true
searchClosing=false
end
end)end
searchButton.MouseButton1Click:Connect(function()searchClosing=false
searchAnimationToken+=1
searchButton.Visible=false
searchField.Visible=true
searchField.Size=UDim2.fromOffset(34,34)searchField.BackgroundTransparency=1
searchFieldStroke.Transparency=1
searchIcon.ImageTransparency=1
searchInput.TextTransparency=1
tween(searchField,{Size=UDim2.fromOffset(220,34),BackgroundTransparency=0,},0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)tween(searchFieldStroke,{Transparency=0.2},0.18)tween(searchIcon,{ImageTransparency=0},0.18)tween(searchInput,{TextTransparency=0},0.18)searchInput:CaptureFocus()end)searchInput.FocusLost:Connect(function(enterPressed,inputThatCausedFocusLost)if inputThatCausedFocusLost and inputThatCausedFocusLost.KeyCode==Enum.KeyCode.Escape then
searchInput.Text=""
closeSearch()return
end
if not enterPressed then
if searchInput.Text=="" then
closeSearch()end
return
end
local query=string.lower(searchInput.Text)for _,candidate in ipairs(self.Tabs)do
if string.find(string.lower(candidate.Name),query,1,true)then
self:SelectTab(candidate)break
end
end
if query=="" then
closeSearch()end
end)local notifyHolder=create("Frame",{Name="Notifications",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-20,1,-20),Size=UDim2.new(0,280,1,-40),BackgroundTransparency=1,Parent=gui,})local function fitToasts()notifyHolder.Size=UDim2.new(0,math.min(280,gui.AbsoluteSize.X-40),1,-40)end
table.insert(self._connections,gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToasts))create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,4),Parent=notifyHolder,})self.NotifyHolder=notifyHolder
self._notifyOrder=0
self._toasts={}self.MaxNotifications=opts.MaxNotifications or 4
self._controlsDirty=true
table.insert(self._connections,body.DescendantAdded:Connect(function()self._controlsDirty=true
end))table.insert(self._connections,body.DescendantRemoving:Connect(function()self._controlsDirty=true
end))self:_enableDrag()self.MaxSize=opts.MaxSize
self.KeepOnScreen=opts.KeepOnScreen~=false
self:_enableResize(opts.MinSize or Vector2.new(480,360))local saving=opts.ConfigurationSaving
if type(saving)=="table" and saving.Enabled~=false then
self.ConfigFolder=saving.FolderName or "JinHubxUI"
self.ConfigName=saving.FileName or "default"
self._autoSaveEnabled=true
else
self.ConfigFolder="JinHubxUI"
self.ConfigName="default"
self._autoSaveEnabled=false
end
table.insert(self._connections,UserInputService.InputBegan:Connect(function(input,gameProcessed)if gameProcessed then
return
end
if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==self.Keybind then
task.defer(function()local consumed=self._consumedKey==input.KeyCode and os.clock()-(self._consumedAt or 0)<0.2
self._consumedKey=nil
if not consumed and not self._destroyed then
self:Toggle(not self.Open)end
end)end
end))pcall(function()if typeof(syn)=="table" and typeof(syn.protect_gui)=="function" then
syn.protect_gui(gui)end
end)gui.Parent=guiParent
scale.Scale=0.9
body.GroupTransparency=1
shadow.ImageTransparency=1
self.BodyStroke.Transparency=1
root.Visible=false
self:_fitToScreen(true)table.insert(self._connections,gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()self:_fitToScreen()self:_clampToScreen()end))local function refreshInputScale()if not self._destroyed then
self:_fitToScreen()self:_clampToScreen()end
end
pcall(function()table.insert(self._connections,UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(refreshInputScale))end)task.defer(function()if not self._destroyed and gui.Parent then
self:_fitToScreen(true)self:_clampToScreen()end
end)if(opts.OpenButton~=nil and opts.OpenButton~=false)or(opts.OpenButton==nil and TOUCH)then
self:_createOpenButton(type(opts.OpenButton)=="table" and opts.OpenButton or{})end
self._introDone=false
table.insert(Library.Windows,self)if opts.Home then
self:_buildHome(type(opts.Home)=="table" and opts.Home or{})end
local loading=opts.Loading
if type(loading)=="table" then
opts.LoadingDuration=loading.Duration or opts.LoadingDuration
opts.LoadingText=loading.Text or loading.Subtitle or opts.LoadingText
opts.LoadingSteps=loading.Steps or opts.LoadingSteps
opts.LoadingTitle=loading.Title or opts.LoadingTitle
loading=loading.Enabled~=false
end
if loading==false then
task.defer(function()self:_playIntro()end)else
self:_showLoader(opts)end
return self
end
Library.CreateWindow=Library.Window
function Library:Notify(opts)local window=Library.Windows[#Library.Windows]if window then
return window:Notify(opts)end
end
function Library:Confirm(opts)local window=Library.Windows[#Library.Windows]if window then
return window:Confirm(opts)end
end
function Library:Dialog(opts)local window=Library.Windows[#Library.Windows]if window then
return window:Dialog(opts)end
end
local function pointInside(point,object)local position,size=object.AbsolutePosition,object.AbsoluteSize
return point.X>=position.X and point.X<=position.X+size.X
and point.Y>=position.Y and point.Y<=position.Y+size.Y
end
local function isShown(object,stopAt,point)local child=object
while child and child~=stopAt and child:IsA("GuiObject")do
if not child.Visible then
return false
end
local parent=child.Parent
if parent and parent~=stopAt and parent:IsA("GuiObject")and(parent.ClipsDescendants or parent:IsA("ScrollingFrame"))and not pointInside(point,parent)then
return false
end
child=parent
end
return true
end
function Window:_refreshControls()local controls={}for _,object in ipairs(self.Body:GetDescendants())do
if object:IsA("GuiButton")or object:IsA("TextBox")or object:GetAttribute("NoDrag")then
table.insert(controls,object)end
end
self._controls=controls
self._controlsDirty=false
end
function Window:_overControl(point)if self._dialog then
return true
end
if self._controlsDirty then
self:_refreshControls()end
for _,object in ipairs(self._controls)do
if object.Parent and pointInside(point,object)and isShown(object,self.Body,point)then
return true
end
end
return false
end
function Window:_enableDrag()local dragging=false
local grabOffset=Vector2.zero
local target=nil
local function centre()local root=self.Root
return root.AbsolutePosition+root.AbsoluteSize*root.AnchorPoint-self.Gui.AbsolutePosition
end
table.insert(self._connections,UserInputService.InputBegan:Connect(function(input)if not isPress(input)then
return
end
if not self.Open or not self.Root.Visible then
return
end
local point=pointerPosition()if not pointInside(point,self.Body)or self:_overControl(point)then
return
end
dragging=true
grabOffset=point-centre()end))table.insert(self._connections,UserInputService.InputEnded:Connect(function(input)if not dragging then
return
end
if isPress(input)then
dragging=false
target=nil
self:_clampToScreen()end
end))table.insert(self._frameSteps,function(deltaTime)if not dragging then
return
end
target=pointerPosition()-grabOffset
local current=centre()local alpha=1-math.exp(-deltaTime*45)local step=current:Lerp(target,alpha)self.Root.Position=UDim2.fromOffset(step.X,step.Y)end)end
local function popIn(object,delay,force)if not object.Visible and not force then
return
end
object.Visible=false
task.delay(delay,function()if not object.Parent then
return
end
local scaleObject=create("UIScale",{Scale=0.94,Parent=object})object.Visible=true
tween(scaleObject,{Scale=1},0.4,Enum.EasingStyle.Back)task.delay(0.4,function()scaleObject:Destroy()end)end)end
function Window:_revealCards(tab,baseDelay)if tab._revealed then
return
end
tab._revealed=true
local index=0
for _,child in ipairs(tab.List:GetChildren())do
if child:IsA("GuiObject")then
popIn(child,(baseDelay or 0)+index*0.035)index+=1
end
end
end
function Window:_playIntro(morph)if self._introDone then
return
end
self._introDone=true
task.delay(1,function()self._autoSaveReady=true
end)local root,body,shadow,scale=self.Root,self.Body,self.Shadow,self.Scale
if self.CurrentTab then
self:_revealCards(self.CurrentTab,morph and 0.15 or 0.25)end
root.Visible=true
if morph then
scale.Scale=self._fitScale or 1
root.Position=UDim2.fromScale(0.5,0.5)tween(body,{GroupTransparency=0},0.3)tween(self.BodyStroke,{Transparency=0},0.3)tween(shadow,{ImageTransparency=0.6},0.3)else
root.Position=UDim2.new(0.5,0,0.5,24)tween(scale,{Scale=self._fitScale or 1},0.5,Enum.EasingStyle.Back)tween(root,{Position=UDim2.fromScale(0.5,0.5)},0.5,Enum.EasingStyle.Quint)tween(body,{GroupTransparency=0},0.35)tween(self.BodyStroke,{Transparency=0},0.35)end
if not morph then
tween(shadow,{ImageTransparency=0.6},0.5)end
for index,tab in ipairs(self.Tabs)do
popIn(tab._button,0.1+index*0.05,true)end
self.Indicator.Visible=false
task.delay(0.15+#self.Tabs*0.05,function()if self.CurrentTab then
self:_placeIndicator(self.CurrentTab)end
end)end
function Window:_showLoader(opts)local duration=opts.LoadingDuration or 1.6
local gui=self.Gui
local loader=create("CanvasGroup",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,16),Size=UDim2.fromOffset(300,132),BackgroundColor3=Theme.Background,BorderSizePixel=0,GroupTransparency=1,ZIndex=10,Parent=gui,})local loaderCorner=corner(loader,UDim.new(0,12))local loaderStroke=stroke(loader,Theme.Stroke,1)edgeHighlight(loader)glow(loader,UDim2.fromOffset(320,140),UDim2.new(1,-20,0,-20),0.85,90)glow(loader,UDim2.fromOffset(240,100),UDim2.new(0,10,1,10),0.9,270)local loaderScale=create("UIScale",{Scale=0.92,Parent=loader})local loaderShadow=create("ImageLabel",{Position=UDim2.fromOffset(-25,-25),Size=UDim2.new(1,50,1,50),BackgroundTransparency=1,Image=Assets.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=loader,})local logoHolder=create("Frame",{Position=UDim2.fromOffset(24,26),Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Parent=loader,})local logo=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(0.5,0.5),Rotation=-14,BackgroundTransparency=1,ImageColor3=Theme.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Parent=logoHolder,})applyIcon(logo,opts.Icon or Assets.Logo)task.delay(0.15,function()tween(logo,{Size=UDim2.fromScale(0.85,0.85),Rotation=0,ImageTransparency=0},0.6,Enum.EasingStyle.Back)end)label({Position=UDim2.fromOffset(78,30),Size=UDim2.new(1,-100,0,22),Text=opts.LoadingTitle or opts.Title or "JinHub",TextSize=21,Parent=loader,})local statusLabel=label({Position=UDim2.fromOffset(78,52),Size=UDim2.new(1,-100,0,16),Text=opts.LoadingText or opts.Subtitle or "Loading",TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=loader,})local track=create("Frame",{Position=UDim2.new(0,24,1,-30),Size=UDim2.new(1,-48,0,4),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,ClipsDescendants=true,Parent=loader,})corner(track,UDim.new(1,0))local fill=create("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Theme.Accent,BorderSizePixel=0,Parent=track,})corner(fill,UDim.new(1,0))local sheen=create("Frame",{Position=UDim2.fromScale(-0.4,0),Size=UDim2.fromScale(0.4,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.6,BorderSizePixel=0,ZIndex=2,Parent=track,})create("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1),}),Parent=sheen,})tween(loader,{GroupTransparency=0,Position=UDim2.fromScale(0.5,0.5)},0.4,Enum.EasingStyle.Quint)tween(loaderScale,{Scale=1},0.5,Enum.EasingStyle.Back)tween(loaderShadow,{ImageTransparency=0.6},0.4)local sweep=TweenService:Create(sheen,TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1),{Position=UDim2.fromScale(1,0),})sweep:Play()tween(fill,{Size=UDim2.fromScale(0.85,1)},duration*0.8,Enum.EasingStyle.Quart)task.spawn(loadLucide)local steps=opts.LoadingSteps or{"Preparing interface","Loading icons","Almost there"}for index,text in ipairs(steps)do
task.delay(duration*(index-1)/#steps,function()if loader.Parent then
statusLabel.Text=text
end
end)end
task.delay(duration,function()tween(fill,{Size=UDim2.fromScale(1,1)},0.25,Enum.EasingStyle.Quint)task.delay(0.25,function()sweep:Cancel()for _,item in ipairs(loader:GetChildren())do
if item:IsA("TextLabel")then
tween(item,{TextTransparency=1},0.15)end
end
for _,item in ipairs(logoHolder:GetChildren())do
tween(item,{ImageTransparency=1},0.15)end
tween(track,{BackgroundTransparency=1},0.15)tween(fill,{BackgroundTransparency=1},0.15)tween(sheen,{BackgroundTransparency=1},0.1)local fit=self._fitScale or 1
local target=self.Root.Size
tween(loader,{Size=UDim2.fromOffset(target.X.Offset*fit,target.Y.Offset*fit),Position=UDim2.fromScale(0.5,0.5),},0.5,Enum.EasingStyle.Quint)tween(loaderCorner,{CornerRadius=UDim.new(0,10)},0.5,Enum.EasingStyle.Quint)tween(loaderScale,{Scale=1},0.5,Enum.EasingStyle.Quint)task.delay(0.28,function()self:_playIntro(true)tween(loader,{GroupTransparency=1},0.25)tween(loaderStroke,{Transparency=1},0.2)tween(loaderShadow,{ImageTransparency=1},0.2)end)task.delay(0.6,function()loader:Destroy()end)end)end)end
function Window:_fitToScreen(instant)local viewport=self.Gui.AbsoluteSize
if viewport.X==0 or viewport.Y==0 then
return
end
local size=self.Root.Size
local renderedSize=self.Root.AbsoluteSize
local currentScale=math.max(self.Scale.Scale,0.001)local width=math.max(size.X.Offset,renderedSize.X/currentScale,1)local height=math.max(size.Y.Offset,renderedSize.Y/currentScale,1)local touchDevice=UserInputService.TouchEnabled
pcall(function()touchDevice=touchDevice or UserInputService.TouchScreenEnabled
end)pcall(function()touchDevice=touchDevice or UserInputService.PreferredInput==Enum.PreferredInput.Touch
end)local compactViewport=touchDevice
or width>=viewport.X*0.7
or height>=viewport.Y*0.75
local maxScale=compactViewport and self.MobileScale or 1
local edgePadding=compactViewport and 36 or 24
local scale=math.min(maxScale,(viewport.X-edgePadding)/width,(viewport.Y-edgePadding)/height)self._fitScale=math.max(scale,compactViewport and 0.35 or 0.45)if self._introDone and self.Open then
if instant then
self.Scale.Scale=self._fitScale
else
tween(self.Scale,{Scale=self._fitScale},0.2)end
end
end
function Window:_clampToScreen()if not self.KeepOnScreen then
return
end
local viewport=self.Gui.AbsoluteSize
local root=self.Root
local half=root.AbsoluteSize/2
local centre=root.AbsolutePosition+half-self.Gui.AbsolutePosition
local clamped=Vector2.new(math.clamp(centre.X,math.min(half.X,viewport.X/2),math.max(viewport.X-half.X,viewport.X/2)),math.clamp(centre.Y,math.min(half.Y,viewport.Y/2),math.max(viewport.Y-half.Y,viewport.Y/2)))if(clamped-centre).Magnitude>0.5 then
tween(root,{Position=UDim2.fromOffset(clamped.X,clamped.Y)},0.25,Enum.EasingStyle.Quint)end
end
function Window:_createOpenButton(opts)local gui=self.Gui
local pill=create("TextButton",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,14),Size=UDim2.fromOffset(0,40),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=Theme.Background,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=30,Parent=gui,})corner(pill,UDim.new(1,0))stroke(pill,Theme.Stroke)padding(pill,12,16)local icon=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(20,20),BackgroundTransparency=1,ImageColor3=Theme.Accent,ScaleType=Enum.ScaleType.Fit,ZIndex=31,Parent=pill,})applyIcon(icon,opts.Icon or Assets.Logo)label({Position=UDim2.fromOffset(28,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=opts.Title or "JinHub",TextSize=16,TextTruncate=Enum.TextTruncate.None,ZIndex=31,Parent=pill,})self.OpenButton=pill
local dragging,moved=false,false
local grab=Vector2.zero
pill.InputBegan:Connect(function(input)if isPress(input)then
dragging=true
moved=false
grab=pointerPosition()-pill.AbsolutePosition
end
end)table.insert(self._connections,UserInputService.InputChanged:Connect(function(input)if not dragging then
return
end
if isMove(input)then
local point=pointerPosition()-grab-gui.AbsolutePosition
if(point-(pill.AbsolutePosition-gui.AbsolutePosition)).Magnitude>3 then
moved=true
end
pill.AnchorPoint=Vector2.new(0,0)pill.Position=UDim2.fromOffset(math.clamp(point.X,0,math.max(gui.AbsoluteSize.X-pill.AbsoluteSize.X,0)),math.clamp(point.Y,0,math.max(gui.AbsoluteSize.Y-pill.AbsoluteSize.Y,0)))end
end))table.insert(self._connections,UserInputService.InputEnded:Connect(function(input)if dragging and isPress(input)then
dragging=false
if not moved then
self:Toggle()end
end
end))end
function Window:_enableResize(minSize)local maxSize=self.MaxSize or Vector2.new(math.huge,math.huge)self._textReferenceSize=Vector2.new(self.Root.Size.X.Offset,self.Root.Size.Y.Offset)self._textScaleFactor=1
function self:_updateTextScale()local reference=self._textReferenceSize
if not reference or reference.X<=0 or reference.Y<=0 then
return
end
local widthRatio=self.Root.Size.X.Offset/reference.X
local heightRatio=self.Root.Size.Y.Offset/reference.Y
local factor=math.clamp(math.min(widthRatio,heightRatio),1,1.25)for _,object in ipairs(self.Root:GetDescendants())do
if object:IsA("TextLabel")or object:IsA("TextButton")or object:IsA("TextBox")then
local baseSize=object:GetAttribute("JinHubBaseTextSize")if not baseSize then
baseSize=object.TextSize/math.max(self._textScaleFactor,0.001)object:SetAttribute("JinHubBaseTextSize",baseSize)end
object.TextSize=math.max(1,math.floor(baseSize*factor*2+0.5)/2)end
end
self._textScaleFactor=factor
end
self:_updateTextScale()table.insert(self._connections,self.Root.DescendantAdded:Connect(function(object)if object:IsA("TextLabel")or object:IsA("TextButton")or object:IsA("TextBox")then
object:SetAttribute("JinHubBaseTextSize",object.TextSize/math.max(self._textScaleFactor,0.001))object.TextSize=math.max(1,math.floor(object.TextSize/math.max(self._textScaleFactor,0.001)*self._textScaleFactor*2+0.5)/2)end
end))local grip=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(1,4,1,4),Size=UDim2.fromOffset(32,32),BackgroundTransparency=1,Active=true,ZIndex=20,Parent=self.Root,})local gripImage=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,-16,0.5,-16),Size=UDim2.fromOffset(96,96),BackgroundTransparency=1,Image="rbxassetid://120997033468887",ImageColor3=Theme.Accent,ImageTransparency=0.8,ZIndex=20,Parent=grip,})local resizing=false
local initialSize=self.Root.Size
local initialPointer=Vector2.zero
local targetSize=nil
grip.InputBegan:Connect(function(input)if isPress(input)then
resizing=true
initialSize=self.Root.Size
initialPointer=pointerPosition()tween(gripImage,{ImageTransparency=0.35},0.1)end
end)grip.MouseEnter:Connect(function()if not resizing then
tween(gripImage,{ImageTransparency=0.35},0.1)end
end)grip.MouseLeave:Connect(function()if not resizing then
tween(gripImage,{ImageTransparency=0.8},0.17)end
end)table.insert(self._connections,UserInputService.InputEnded:Connect(function(input)if resizing and isPress(input)then
resizing=false
tween(gripImage,{ImageTransparency=0.8},0.17)if targetSize then
self.Root.Size=UDim2.fromOffset(targetSize.X,targetSize.Y)targetSize=nil
end
self:_updateTextScale()self:_fitToScreen()self:_clampToScreen()end
end))table.insert(self._frameSteps,function(deltaTime)if not resizing then
return
end
local delta=(pointerPosition()-initialPointer)/self.Scale.Scale
targetSize=Vector2.new(math.clamp(initialSize.X.Offset+delta.X*2,minSize.X,maxSize.X),math.clamp(initialSize.Y.Offset+delta.Y*2,minSize.Y,maxSize.Y))local current=Vector2.new(self.Root.Size.X.Offset,self.Root.Size.Y.Offset)local alpha=1-math.exp(-deltaTime*35)local step=current:Lerp(targetSize,alpha)step=Vector2.new(math.floor(step.X+0.5),math.floor(step.Y+0.5))if step~=current then
self.Root.Size=UDim2.fromOffset(step.X,step.Y)end
end)end
local function configPath(self,name)return self.ConfigFolder.."/"..name..".json"
end
local function fileApiAvailable()return type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function"
end
local function ensureFolder(folder)if type(isfolder)=="function" and type(makefolder)=="function" and not isfolder(folder)then
makefolder(folder)end
end
local function serializeFlag(element)local kind=element._type
local value=element:Get()if kind=="Keybind" then
return{Type=kind,Value=value and value.Name or nil}elseif kind=="ColorPicker" then
return{Type=kind,Value={value.R,value.G,value.B}}end
return{Type=kind,Value=value}end
local function deserializeFlag(element,entry,silent)local kind=element._type
local value=entry.Value
if kind=="Keybind" then
element:Set(value and Enum.KeyCode[value]or nil,silent)elseif kind=="ColorPicker" then
if type(value)=="table" then
element:Set(Color3.new(value[1],value[2],value[3]),silent)end
elseif value~=nil then
element:Set(value,silent)end
end
function Window:SaveConfig(name)name=name or self.ConfigName
if not fileApiAvailable()then
return false,"file API unavailable"
end
ensureFolder(self.ConfigFolder)local data={}for flag,element in pairs(Library.Flags)do
if element._type and type(element.Get)=="function" then
data[flag]=serializeFlag(element)end
end
local ok,err=pcall(function()writefile(configPath(self,name),HttpService:JSONEncode(data))end)if ok then
self.ConfigName=name
end
return ok,err
end
function Window:LoadConfig(name,silent)name=name or self.ConfigName
if not fileApiAvailable()then
return false,"file API unavailable"
end
local path=configPath(self,name)if not isfile(path)then
return false,"no config named "..name
end
local ok,data=pcall(function()return HttpService:JSONDecode(readfile(path))end)if not ok or type(data)~="table" then
return false,"config is not valid JSON"
end
local previous=self._autoSaveEnabled
self._autoSaveEnabled=false
for flag,entry in pairs(data)do
local element=Library.Flags[flag]if element and type(element.Set)=="function" and type(entry)=="table" and entry.Type==element._type then
pcall(deserializeFlag,element,entry,silent==true)end
end
self._autoSaveEnabled=previous
self._autoSaveReady=true
self.ConfigName=name
return true
end
function Window:DeleteConfig(name)if not fileApiAvailable()or type(delfile)~="function" then
return false,"file API unavailable"
end
local path=configPath(self,name)if not isfile(path)then
return false,"no config named "..name
end
delfile(path)return true
end
function Window:ListConfigs()local names={}if type(listfiles)~="function" or type(isfolder)~="function" or not isfolder(self.ConfigFolder)then
return names
end
for _,path in ipairs(listfiles(self.ConfigFolder))do
local name=path:match("([^/\\]+)%.json$")if name then
table.insert(names,name)end
end
table.sort(names)return names
end
function Window:_autoSave()if not self._autoSaveEnabled or self._destroyed or not self._autoSaveReady then
return
end
if self._autoSavePending then
return
end
self._autoSavePending=true
task.delay(0.5,function()self._autoSavePending=false
if not self._destroyed then
self:SaveConfig(self.ConfigName)end
end)end
local function emptyState(parent,icon,text)local holder=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,-10),Size=UDim2.fromOffset(200,70),BackgroundTransparency=1,Parent=parent,})local image=create("ImageLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,0),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,ImageColor3=Theme.Muted,ImageTransparency=0.15,ScaleType=Enum.ScaleType.Fit,Parent=holder,})applyIcon(image,icon)local caption=label({Position=UDim2.fromOffset(0,36),Size=UDim2.new(1,0,0,16),Text=text,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextXAlignment=Enum.TextXAlignment.Center,Parent=holder,})return holder,caption,image
end
local function statRow(parent,order,icon,title)local card=create("Frame",{Size=UDim2.new(0.5,-4,0,62),BackgroundColor3=Theme.Surface2,BorderSizePixel=0,LayoutOrder=order,Parent=parent,})corner(card)stroke(card)card:SetAttribute("NoDrag",true)if icon then
glowIcon(card,icon,Theme.Muted,UDim2.new(0,14,0,21))end
label({Position=UDim2.fromOffset(icon and 36 or 14,12),Size=UDim2.new(1,-(icon and 50 or 28),0,16),Text=title,TextSize=13,TextColor3=Theme.Muted,Parent=card,})return label({Position=UDim2.fromOffset(14,34),Size=UDim2.new(1,-28,0,18),Text="…",TextSize=16,Parent=card,})end
local function fadeCard(card)local parts={}local function collect(object)for _,child in ipairs(object:GetChildren())do
if child:IsA("TextLabel")or child:IsA("TextButton")or child:IsA("TextBox")then
table.insert(parts,{child,"TextTransparency",child.TextTransparency})elseif child:IsA("ImageLabel")or child:IsA("ImageButton")then
table.insert(parts,{child,"ImageTransparency",child.ImageTransparency})elseif child:IsA("UIStroke")then
table.insert(parts,{child,"Transparency",child.Transparency})elseif child:IsA("Frame")then
table.insert(parts,{child,"BackgroundTransparency",child.BackgroundTransparency})end
collect(child)end
end
if card:IsA("Frame")then
table.insert(parts,{card,"BackgroundTransparency",card.BackgroundTransparency})end
collect(card)for _,part in ipairs(parts)do
part[1][part[2]]=1
tween(part[1],{[part[2]]=part[3]},0.28)end
end
local function fadeSlideIn(group,restY)restY=restY or 0
group.GroupTransparency=1
group.Position=UDim2.fromOffset(0,restY+14)group.Visible=true
tween(group,{GroupTransparency=0,Position=UDim2.fromOffset(0,restY)},0.32,Enum.EasingStyle.Quint)end
function Window:_buildHome(opts)local tab=self:Tab({Name=opts.Name or "Home",Desc=opts.Desc,Icon=opts.Icon or "house",})local list=tab.List
local pages=opts.Pages or opts.Tabs
local panels={}local strip=nil
if type(pages)=="table" and #pages>0 then
strip=create("Frame",{Size=UDim2.new(1,0,0,self.NewElements and 38 or 32),BackgroundTransparency=1,LayoutOrder=1,Parent=list,})create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=strip,})end
local greeting=opts.Greeting
if greeting==nil then
local hour=tonumber(os.date("%H"))or 12
local part=hour<12 and "morning" or(hour<18 and "afternoon" or "evening")greeting="Good "..part.."."
end
local header=create("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=Theme.Surface2,BorderSizePixel=0,LayoutOrder=2,Parent=list,})header:SetAttribute("NoDrag",true)corner(header)stroke(header)local avatar=create("ImageLabel",{Position=UDim2.fromOffset(12,11),Size=UDim2.fromOffset(36,36),BackgroundColor3=Theme.Surface,BorderSizePixel=0,Parent=header,})corner(avatar,UDim.new(0,8))stroke(avatar)task.spawn(function()local ok,url=pcall(function()return Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)end)if ok and url then
avatar.Image=url
end
end)label({Position=UDim2.fromOffset(58,11),Size=UDim2.new(1,-72,0,18),Text=(opts.Welcome or "Hello, ")..LocalPlayer.DisplayName,TextSize=16,Parent=header,})label({Position=UDim2.fromOffset(58,30),Size=UDim2.new(1,-72,0,16),Text=greeting,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=header,})local infoPanel=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=3,Parent=list,})create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=infoPanel,})if opts.Sections~=false then
local heading=create("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,LayoutOrder=1,Parent=infoPanel,})local headingText=label({Position=UDim2.fromOffset(2,6),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=string.upper(opts.SectionName or "System info"),TextSize=13,TextColor3=Theme.Muted,TextTruncate=Enum.TextTruncate.None,Parent=heading,})local rule=create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0,14),Size=UDim2.new(1,-12,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,Parent=heading,})local function fitRule()rule.Size=UDim2.new(1,-(headingText.AbsoluteSize.X+14),0,1)end
headingText:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitRule)task.defer(fitRule)end
local grid=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2,Parent=infoPanel,})create("UIGridLayout",{CellSize=UDim2.new(0.5,-4,0,62),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=grid,})local show=opts.Stats or{"FPS","Ping","Executor","Game","Region","Time"}local enabled={}for _,name in ipairs(show)do
enabled[name]=true
end
local order=0
local function add(name,icon,title)if not enabled[name]then
return nil
end
order+=1
return statRow(grid,order,icon,title)end
local fpsValue=add("FPS","activity","FPS")local pingValue=add("Ping","wifi","Ping")local executorValue=add("Executor","terminal","Executor")local gameValue=add("Game","gamepad-2","Game")local regionValue=add("Region","globe","Server region")local timeValue=add("Time","clock","Time of day")local playersValue=add("Players","users","Players")local uptimeValue=add("Uptime","timer","Session")if executorValue then
executorValue.Text=detectExecutor()end
if gameValue then
gameValue.Text="Loading"
task.spawn(function()gameValue.Text=detectGameName()end)end
if regionValue then
regionValue.Text="Loading"
detectRegion(function(region)regionValue.Text=region
end)end
local frames=0
local started=os.clock()self:_listen("Render",function()frames+=1
end)task.spawn(function()while not self._destroyed and tab.List.Parent and tab._page.Parent do
if not self.Open or self.CurrentTab~=tab then
frames=0
task.wait(1)continue
end
if fpsValue then
fpsValue.Text=tostring(frames)end
frames=0
if pingValue then
local ok,ping=pcall(function()return math.floor(LocalPlayer:GetNetworkPing()*1000)end)pingValue.Text=(ok and ping or 0).." ms"
end
if timeValue then
timeValue.Text=os.date(opts.TimeFormat or "%H:%M")end
if playersValue then
playersValue.Text=#Players:GetPlayers().." / "..Players.MaxPlayers
end
if uptimeValue then
local elapsed=math.floor(os.clock()-started)uptimeValue.Text=string.format("%d:%02d",math.floor(elapsed/60),elapsed%60)end
task.wait(1)end
end)table.insert(panels,{Title=opts.SectionName or "Details",Icon=opts.TabIcon or "layout-grid",Frame=infoPanel})if strip then
for _,page in ipairs(pages)do
local panel=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false,LayoutOrder=3,Parent=list,})create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=panel,})if type(page.Content)=="string" then
local card=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.Surface2,BorderSizePixel=0,LayoutOrder=1,Parent=panel,})card:SetAttribute("NoDrag",true)corner(card)stroke(card)padding(card,14,14,12,14)label({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=page.Content,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,Parent=card,})end
if type(page.Entries)=="table" then
local categoryOrder={fix=1,optimization=2,added=3,changed=4,removed=5,security=6,}local function getChangeGroups(changes)local groups={}local first=changes[1]if first~=nil then
if type(first)~="table" then
return nil
end
for _,group in ipairs(changes)do
if type(group)=="table" then
local title=group.Title or group.Name or group.Category
local items=group.Items or group.Changes or group.Entries
if type(title)=="string" and type(items)=="table" and #items>0 then
table.insert(groups,{Title=title,Items=items})end
end
end
else
local names={}for name,items in pairs(changes)do
if type(name)=="string" and type(items)=="table" then
table.insert(names,name)end
end
table.sort(names,function(a,b)local aKey,bKey=string.lower(a),string.lower(b)local aOrder,bOrder=categoryOrder[aKey]or math.huge,categoryOrder[bKey]or math.huge
if aOrder==bOrder then
return aKey<bKey
end
return aOrder<bOrder
end)for _,name in ipairs(names)do
local items=changes[name]if #items>0 then
table.insert(groups,{Title=name,Items=items})end
end
end
return #groups>0 and groups or nil
end
for index,entry in ipairs(page.Entries)do
local card=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.Surface2,BorderSizePixel=0,LayoutOrder=index,Parent=panel,})card:SetAttribute("NoDrag",true)corner(card)stroke(card)padding(card,14,14,12,14)create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=card,})local head=create("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=1,Parent=card,})label({Size=UDim2.new(1,-70,1,0),Text=entry.Title or entry.Version or "Update",TextSize=15,Parent=head,})if entry.Date or entry.Tag then
local chip=create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(0,20),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=Theme.Surface,BorderSizePixel=0,Parent=head,})corner(chip,UDim.new(0,5))stroke(chip)padding(chip,8,8)label({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=entry.Tag or entry.Date,TextSize=12,TextColor3=Theme.Muted,TextTruncate=Enum.TextTruncate.None,Parent=chip,})end
local body=entry.Content or entry.Body
local changeGroups=type(entry.Changes)=="table" and getChangeGroups(entry.Changes)or nil
if changeGroups then
body=nil
local groupsHolder=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2,Parent=card,})create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=groupsHolder,})for groupIndex,group in ipairs(changeGroups)do
local groupFrame=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=groupIndex,Parent=groupsHolder,})create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=groupFrame,})label({Size=UDim2.new(1,0,0,18),Text="[-] "..group.Title..":",TextSize=14,FontFace=Fonts.Bold,LayoutOrder=1,Parent=groupFrame,})for itemIndex,change in ipairs(group.Items)do
label({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text="•  "..tostring(change),TextSize=14,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=itemIndex+1,Parent=groupFrame,})end
end
elseif type(entry.Changes)=="table" and #entry.Changes>0 then
body="• "..table.concat(entry.Changes,"\n• ")end
if body then
label({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=body,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2,Parent=card,})end
end
end
if type(page.Build)=="function" then
safeCall(page.Build,panel)for _,child in ipairs(panel:GetChildren())do
if child:IsA("GuiObject")then
child:SetAttribute("NoDrag",true)end
end
end
table.insert(panels,{Title=page.Name or page.Title or "Page",Icon=page.Icon,Frame=panel})end
local buttons={}local function select(index,instant)local changed=self._homeIndex~=index
self._homeIndex=index
header.Visible=index==1
if index==1 and changed and not instant then
fadeCard(header)end
for position,entry in ipairs(panels)do
local on=position==index
local frame=entry.Frame
frame.Visible=on
if on and changed and not instant then
for _,child in ipairs(frame:GetChildren())do
if child:IsA("GuiObject")then
fadeCard(child)end
end
end
local button=buttons[position]if button then
tween(button.Frame,{BackgroundTransparency=on and 0 or 1},0.15)tween(button.Stroke,{Transparency=on and 0 or 1},0.15)tween(button.Label,{TextColor3=on and Theme.Text or Theme.Muted},0.15)if button.Icon then
tween(button.Icon,{ImageColor3=on and Theme.Accent or Theme.Muted},0.15)end
end
end
end
for index,entry in ipairs(panels)do
local button=create("TextButton",{Size=UDim2.fromOffset(0,32),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=Theme.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=index,Parent=strip,})corner(button,UDim.new(0,7))local buttonStroke=stroke(button,Theme.Stroke,1)padding(button,12,12)local iconImage
if entry.Icon then
iconImage=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=Theme.Muted,ScaleType=Enum.ScaleType.Fit,Parent=button,})applyIcon(iconImage,entry.Icon)end
local text=label({Position=UDim2.fromOffset(iconImage and 20 or 0,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=entry.Title,TextSize=16,TextColor3=Theme.Muted,TextTruncate=Enum.TextTruncate.None,Parent=button,})buttons[index]={Frame=button,Stroke=buttonStroke,Label=text,Icon=iconImage}button.MouseEnter:Connect(function()if self._homeIndex~=index then
tween(button,{BackgroundTransparency=0.4},0.12)tween(buttonStroke,{Transparency=0.5},0.12)end
end)button.MouseLeave:Connect(function()if self._homeIndex~=index then
tween(button,{BackgroundTransparency=1},0.2)tween(buttonStroke,{Transparency=1},0.2)end
end)button.MouseButton1Click:Connect(function()select(index)end)end
select(1)end
tab._order=10
self.Home=tab
return tab
end
function Window:Tab(opts,icon)opts=normalize(opts,{Title="Name",Description="Desc"})if icon~=nil and opts.Icon==nil then
opts.Icon=icon
end
local tab=setmetatable({Name=opts.Name or "Tab",Window=self,_order=0,},Tab)local button=create("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=Theme.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=self:_nextSidebarOrder(),Parent=self.TabList,})corner(button)local buttonStroke=stroke(button,Theme.Stroke,1)tab._button=button
local hasIcon=opts.Icon~=nil
if hasIcon then
local iconImage=create("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=Theme.Muted,ScaleType=Enum.ScaleType.Fit,Parent=button,})applyIcon(iconImage,opts.Icon)tab._icon=iconImage
end
tab._label=label({Position=UDim2.fromOffset(hasIcon and 36 or 14,0),Size=UDim2.new(1,-(hasIcon and 44 or 22),1,0),Text=tab.Name,TextColor3=Theme.Muted,Parent=button,})local page=create("Frame",{Name=tab.Name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,Parent=self.Content,})tab._page=page
local showTabTitle=opts.ShowTabTitle==true
if showTabTitle then
label({Position=UDim2.fromOffset(24,20),Size=UDim2.new(1,-72,0,24),Text=tab.Name,TextSize=23,Parent=page,})end
if showTabTitle and opts.Desc then
label({Position=UDim2.fromOffset(24,44),Size=UDim2.new(1,-72,0,16),Text=opts.Desc,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,Parent=page,})end
if showTabTitle then
local dividerY=opts.Desc and 68 or 52
create("Frame",{Position=UDim2.new(0,0,0,dividerY),Size=UDim2.new(1,-24,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,Parent=page,})end
local listTop=showTabTitle and(opts.Desc and 80 or 64)or(opts.Desc and 70 or 58)local list=create("ScrollingFrame",{Position=UDim2.fromOffset(0,listTop),Size=UDim2.new(1,0,1,-listTop),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Theme.Accent,ScrollBarImageTransparency=0.5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=page,})local contentInset=self.NewElements and 15 or 24
padding(list,contentInset,contentInset,2,24)create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,self.NewElements and 2 or 8),Parent=list,})tab.List=list
local empty=emptyState(page,opts.Icon or "layout-grid",opts.EmptyText or "Nothing here yet")local elementCount=0
list.ChildAdded:Connect(function(child)if child:IsA("GuiObject")then
elementCount+=1
empty.Visible=false
end
end)list.ChildRemoved:Connect(function(child)if child:IsA("GuiObject")then
elementCount=math.max(elementCount-1,0)empty.Visible=elementCount<=0
end
end)empty.Visible=true
button.MouseEnter:Connect(function()if self.CurrentTab~=tab then
tween(button,{BackgroundTransparency=0.4},0.12)tween(buttonStroke,{Transparency=0.5},0.12)end
end)button.MouseLeave:Connect(function()if self.CurrentTab~=tab then
tween(button,{BackgroundTransparency=1},0.2)tween(buttonStroke,{Transparency=1},0.2)end
end)button.MouseButton1Click:Connect(function()self:SelectTab(tab)end)tab._stroke=buttonStroke
if not self._introDone then
button.Visible=false
end
table.insert(self.Tabs,tab)if #self.Tabs==1 then
task.defer(function()self:SelectTab(tab)end)end
return tab
end
Window.CreateTab=Window.Tab
function Window:_nextSidebarOrder()self._sidebarOrder=(self._sidebarOrder or 0)+1
return self._sidebarOrder
end
function Window:Divider()local divider=create("Frame",{Name="WindowDivider",Size=UDim2.new(1,0,0,8),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=self:_nextSidebarOrder(),Parent=self.TabList,})divider:SetAttribute("NoDrag",true)create("Frame",{Name="Line",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,6,0.5,0),Size=UDim2.new(1,-12,0,1),BackgroundColor3=Theme.Stroke,BorderSizePixel=0,Parent=divider,})return divider
end
function Window:Dialog(opts)opts=normalize(opts,{Text="Content",Message="Content"})if self._dialog then
self._dialog.Close()end
local WIDTH=300
local PAD=18
local overlay=create("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=40,Parent=self.Body,})local card=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,10),Size=UDim2.fromOffset(WIDTH,120),BackgroundColor3=Theme.Background,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=41,Parent=overlay,})corner(card,UDim.new(0,10))local cardStroke=stroke(card,Theme.Stroke,1)local cardScale=create("UIScale",{Scale=0.94,Parent=card})local fading={}local titleOffset=0
if opts.Icon then
local holder,image=glowIcon(card,opts.Icon,Theme.Accent,UDim2.new(0,PAD,0,PAD+9))image.ImageTransparency=1
holder.ZIndex=42
image.ZIndex=42
table.insert(fading,{image,"ImageTransparency",0})titleOffset=24
end
local title=label({Position=UDim2.fromOffset(PAD+titleOffset,PAD),Size=UDim2.new(1,-(PAD*2+titleOffset),0,18),Text=opts.Title or "Are you sure?",TextSize=16,TextTransparency=1,ZIndex=42,Parent=card,})table.insert(fading,{title,"TextTransparency",0})local contentHeight=0
if opts.Content then
local content=label({Position=UDim2.fromOffset(PAD,PAD+24),Size=UDim2.new(1,-PAD*2,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=opts.Content,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextWrapped=true,TextTransparency=1,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=42,Parent=card,})table.insert(fading,{content,"TextTransparency",0})contentHeight=math.max(content.TextBounds.Y,16)+6
content:GetPropertyChangedSignal("TextBounds"):Connect(function()local newHeight=math.max(content.TextBounds.Y,16)+6
if newHeight~=contentHeight then
contentHeight=newHeight
card.Size=UDim2.fromOffset(WIDTH,PAD+24+contentHeight+12+34+PAD)local rowFrame=card:FindFirstChild("ButtonRow")if rowFrame then
rowFrame.Position=UDim2.fromOffset(PAD,PAD+24+contentHeight+12)end
end
end)end
local row=create("Frame",{Name="ButtonRow",Position=UDim2.fromOffset(PAD,PAD+24+contentHeight+12),Size=UDim2.new(1,-PAD*2,0,34),BackgroundTransparency=1,ZIndex=42,Parent=card,})create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=row,})card.Size=UDim2.fromOffset(WIDTH,PAD+24+contentHeight+12+34+PAD)local dialog={}local closed=false
function dialog.Close()if closed then
return
end
closed=true
if self._dialog==dialog then
self._dialog=nil
end
tween(overlay,{BackgroundTransparency=1},0.18)tween(card,{BackgroundTransparency=1,Position=UDim2.new(0.5,0,0.5,8)},0.18,Enum.EasingStyle.Quint)tween(cardScale,{Scale=0.96},0.18,Enum.EasingStyle.Quint)tween(cardStroke,{Transparency=1},0.12)for _,entry in ipairs(fading)do
tween(entry[1],{[entry[2]]=1},0.12)end
task.delay(0.2,function()overlay:Destroy()end)end
for index,spec in ipairs(opts.Buttons or{})do
local primary=spec.Variant=="Primary"
local buttonFrame=create("TextButton",{Size=UDim2.fromOffset(0,34),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=primary and Theme.Accent or Theme.Surface2,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,LayoutOrder=index,ZIndex=43,Parent=row,})corner(buttonFrame,UDim.new(0,7))local buttonStroke=stroke(buttonFrame,primary and Theme.Accent or Theme.Stroke,1)padding(buttonFrame,14,14)local text=label({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=spec.Title or spec.Name or "OK",TextSize=16,TextColor3=primary and Theme.AccentDark or Theme.Text,TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=1,ZIndex=44,Parent=buttonFrame,})local restBg=primary and 0.12 or 0
local restStroke=primary and 0.4 or 0
table.insert(fading,{buttonFrame,"BackgroundTransparency",restBg})table.insert(fading,{buttonStroke,"Transparency",restStroke})table.insert(fading,{text,"TextTransparency",0})buttonFrame.MouseEnter:Connect(function()if closed then
return
end
if primary then
tween(buttonFrame,{BackgroundTransparency=0},0.12)tween(buttonStroke,{Transparency=0},0.12)else
tween(buttonStroke,{Color=Theme.StrokeHover},0.12)end
end)buttonFrame.MouseLeave:Connect(function()if closed then
return
end
if primary then
tween(buttonFrame,{BackgroundTransparency=restBg},0.2)tween(buttonStroke,{Transparency=restStroke},0.2)else
tween(buttonStroke,{Color=Theme.Stroke},0.2)end
end)buttonFrame.MouseButton1Click:Connect(function()dialog.Close()safeCall(spec.Callback)end)end
if opts.CloseOnBackdrop~=false then
overlay.MouseButton1Click:Connect(function()dialog.Close()safeCall(opts.OnCancel)end)end
self._dialog=dialog
tween(overlay,{BackgroundTransparency=0.45},0.25)tween(card,{BackgroundTransparency=0,Position=UDim2.fromScale(0.5,0.5)},0.3,Enum.EasingStyle.Quint)tween(cardStroke,{Transparency=0},0.25)tween(cardScale,{Scale=1},0.4,Enum.EasingStyle.Back)for _,entry in ipairs(fading)do
tween(entry[1],{[entry[2]]=entry[3]},0.25)end
return dialog
end
function Window:Confirm(opts)opts=normalize(opts,{Text="Content",Message="Content"})return self:Dialog({Title=opts.Title or "Are you sure?",Content=opts.Content,Icon=opts.Icon,OnCancel=opts.OnCancel,Buttons={{Title=opts.CancelText or "Cancel",Callback=opts.OnCancel},{Title=opts.ConfirmText or "Confirm",Variant="Primary",Callback=opts.Callback},},})end
function Window:_listen(kind,handler,owner)local list=self._inputListeners[kind]table.insert(list,handler)local function disconnect()for index,entry in ipairs(list)do
if entry==handler then
table.remove(list,index)break
end
end
end
if owner then
owner._listeners=owner._listeners or{}table.insert(owner._listeners,disconnect)end
return disconnect
end
function Window:_registerSectionHover(update,owner)local targets=self._sectionHoverTargets
if not targets then
targets={}self._sectionHoverTargets=targets
end
local entry={Update=update}table.insert(targets,entry)if not self._sectionHoverRefresh then
local refreshQueued=false
local function refresh()if #targets==0 then
return
end
if not self.Open or self._destroyed then
for index=#targets,1,-1 do
local target=targets[index]if target then
target.Update(false)end
end
return
end
local pointer=pointerPosition()for index=#targets,1,-1 do
local target=targets[index]if target then
target.Update(pointer)end
end
end
local function queueRefresh()if refreshQueued then
return
end
refreshQueued=true
task.defer(function()refreshQueued=false
refresh()end)end
self._sectionHoverRefresh=queueRefresh
self:_listen("Changed",function(input)if isMove(input)or input.UserInputType==Enum.UserInputType.MouseWheel then
queueRefresh()end
end)self:_listen("Began",function(input)if isPress(input)then
queueRefresh()end
end)end
local function disconnect()for index,target in ipairs(targets)do
if target==entry then
table.remove(targets,index)break
end
end
end
if owner then
owner._listeners=owner._listeners or{}table.insert(owner._listeners,disconnect)end
return disconnect
end
function Window:_indicatorY(tab)local list=self.TabList
local scale=self.Scale.Scale
return(tab._button.AbsolutePosition.Y-list.AbsolutePosition.Y+tab._button.AbsoluteSize.Y/2)/scale+list.Position.Y.Offset
end
function Window:_placeIndicator(tab)local indicator=self.Indicator
local targetY=self:_indicatorY(tab)if not indicator.Visible then
indicator.Visible=true
indicator.Position=UDim2.fromOffset(6,targetY)indicator.Size=UDim2.fromOffset(3,0)end
tween(indicator,{Position=UDim2.fromOffset(6,targetY),Size=UDim2.fromOffset(3,18)},0.35,Enum.EasingStyle.Back)end
function Window:SelectTab(tab)if self.CurrentTab==tab then
return
end
local previous=self.CurrentTab
self.CurrentTab=tab
self:_settleTransition()local generation=(self._transitionGeneration or 0)+1
self._transitionGeneration=generation
if previous then
tween(previous._button,{BackgroundTransparency=1},0.2)tween(previous._stroke,{Transparency=1},0.2)tween(previous._label,{TextColor3=Theme.Muted},0.2)if previous._icon then
tween(previous._icon,{ImageColor3=Theme.Muted},0.2)end
local outLayer=self._outLayer
previous._page.Parent=outLayer
self._outPage=previous._page
outLayer.GroupTransparency=0
outLayer.Position=UDim2.fromOffset(0,0)outLayer.Visible=true
tween(outLayer,{GroupTransparency=1,Position=UDim2.fromOffset(0,-10)},0.18)task.delay(0.18,function()if self._transitionGeneration==generation then
self:_settleOut()end
end)end
tween(tab._button,{BackgroundTransparency=0},0.2)tween(tab._stroke,{Transparency=0},0.2)tween(tab._label,{TextColor3=Theme.Text},0.2)if tab._icon then
tween(tab._icon,{ImageColor3=Theme.Accent},0.2)end
self:_placeIndicator(tab)local page=tab._page
page.Position=UDim2.fromOffset(0,0)page.Visible=true
page.Parent=self._inLayer
self._inPage=page
fadeSlideIn(self._inLayer)if self._sectionHoverRefresh then
self._sectionHoverRefresh()end
task.delay(0.32,function()if self._transitionGeneration==generation then
self:_settleIn()end
end)end
function Window:_settleOut()local page=self._outPage
if page then
page.Parent=self.Content
page.Visible=false
self._outPage=nil
end
self._outLayer.Visible=false
end
function Window:_settleIn()local page=self._inPage
if page then
page.Parent=self.Content
page.Position=UDim2.fromOffset(0,0)self._inPage=nil
end
self._inLayer.Visible=false
end
function Window:_settleTransition()self:_settleOut()self:_settleIn()end
function Window:Toggle(open)if not self._introDone then
return
end
if open==nil then
open=not self.Open
end
if open==self.Open then
return
end
if not open and self._openDropdown and self._openDropdown.SetOpen then
self._openDropdown:SetOpen(false)self._openDropdown=nil
end
self.Open=open
if self._sectionHoverRefresh then
self._sectionHoverRefresh()end
if open then
self.Root.Visible=true
tween(self.Scale,{Scale=self._fitScale or 1},0.4,Enum.EasingStyle.Back)tween(self.Body,{GroupTransparency=0},0.25)tween(self.BodyStroke,{Transparency=0},0.25)tween(self.Shadow,{ImageTransparency=0.6},0.3)else
tween(self.Scale,{Scale=(self._fitScale or 1)*0.94},0.2,Enum.EasingStyle.Quint)tween(self.Body,{GroupTransparency=1},0.16)tween(self.BodyStroke,{Transparency=1},0.12)tween(self.Shadow,{ImageTransparency=1},0.16)task.delay(0.2,function()if not self.Open then
self.Root.Visible=false
end
end)end
end
function Window:SetKeepOnScreen(enabled)self.KeepOnScreen=enabled~=false
if self.KeepOnScreen then
self:_clampToScreen()end
end
function Window:SetKeybind(keyCode)self.Keybind=keyCode
self._keyChipLabel.Text=keyName(keyCode)end
function Window:Tag(opts)opts=normalize(opts,{})if self._statusTag then
self._statusTag:Destroy()self._statusTag=nil
end
if not self.StatusBar then
return nil
end
local tag=create("Frame",{Name="StatusBarTag",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(0,20),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=6,Parent=self.StatusBar,})corner(tag,UDim.new(0,5))stroke(tag)padding(tag,7,7)local titleLeft=0
if opts.Icon then
local icon=create("ImageLabel",{Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=Theme.Accent,ScaleType=Enum.ScaleType.Fit,ZIndex=7,Parent=tag,})applyIcon(icon,opts.Icon)titleLeft=20
end
label({Position=UDim2.fromOffset(titleLeft,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=tostring(opts.Title or "Tag"),TextSize=12,FontFace=Fonts.Medium,TextColor3=Theme.Muted,TextTruncate=Enum.TextTruncate.None,ZIndex=7,Parent=tag,})self._statusTag=tag
if self._placeGameNameLabel then
local function updateNamePosition()self._placeGameNameLabel(tag.AbsoluteSize.X/math.max(self.Scale.Scale,0.001))end
tag:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateNamePosition)task.defer(updateNamePosition)end
return tag
end
function Window:Notify(opts)opts=normalize(opts,{Text="Content",Message="Content",Image="Icon"})local duration=opts.Duration or 4
local titleColor=NOTIFY_COLORS[opts.Type]or Theme.Text
self._notifyOrder=self._notifyOrder+1
local outer=create("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,LayoutOrder=self._notifyOrder,Parent=self.NotifyHolder,})local slide=create("Frame",{Position=UDim2.fromOffset(320,0),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=outer,})local shadow=create("ImageLabel",{Position=UDim2.fromOffset(-20,-20),Size=UDim2.new(1,40,1,40),BackgroundTransparency=1,Image=Assets.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=slide,})local toast=create("CanvasGroup",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.Background,BorderSizePixel=0,GroupTransparency=1,Parent=slide,})corner(toast,UDim.new(0,10))local toastStroke=stroke(toast,Theme.Stroke)edgeHighlight(toast)glow(toast,UDim2.fromOffset(260,120),UDim2.new(1,-10,0,-10),0.86,90)local inner=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=toast,})padding(inner,16,16,14,24)local titleOffset=0
if opts.Icon then
glowIcon(inner,opts.Icon,titleColor==Theme.Text and Theme.Accent or titleColor,UDim2.new(0,0,0,8))titleOffset=24
end
label({Position=UDim2.fromOffset(titleOffset,0),Size=UDim2.new(1,-28-titleOffset,0,16),Text=opts.Title or "Notification",TextSize=15,TextColor3=titleColor,Parent=inner,})local closeButton=create("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,6,0,-5),Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,Text="×",TextColor3=Theme.Muted,TextSize=23,FontFace=Fonts.Bold,AutoButtonColor=false,Parent=inner,})closeButton.MouseEnter:Connect(function()tween(closeButton,{TextColor3=Theme.Text},0.15)end)closeButton.MouseLeave:Connect(function()tween(closeButton,{TextColor3=Theme.Muted},0.2)end)if opts.Content then
label({Position=UDim2.fromOffset(titleOffset,21),Size=UDim2.new(1,-titleOffset,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=opts.Content,TextSize=16,FontFace=Fonts.Regular,TextColor3=Theme.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,Parent=inner,})end
local track=create("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-8),Size=UDim2.new(1,-32,0,3),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,Parent=toast,})corner(track,UDim.new(1,0))local progress=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Theme.Accent,BorderSizePixel=0,Parent=track,})corner(progress,UDim.new(1,0))task.defer(function()if outer.Parent then
tween(outer,{Size=UDim2.new(1,0,0,toast.AbsoluteSize.Y)},0.3,Enum.EasingStyle.Quint)end
end)tween(slide,{Position=UDim2.fromOffset(0,0)},0.5,Enum.EasingStyle.Back)tween(toast,{GroupTransparency=0},0.3)tween(shadow,{ImageTransparency=0.6},0.4)tween(progress,{Size=UDim2.fromScale(0,1)},duration,Enum.EasingStyle.Linear)local dismissed=false
local function dismiss()if dismissed then
return
end
dismissed=true
for index,entry in ipairs(self._toasts)do
if entry==dismiss then
table.remove(self._toasts,index)break
end
end
tween(slide,{Position=UDim2.fromOffset(320,0)},0.3,Enum.EasingStyle.Quint)tween(toast,{GroupTransparency=1},0.2)tween(toastStroke,{Transparency=1},0.15)tween(shadow,{ImageTransparency=1},0.2)task.delay(0.22,function()outer.ClipsDescendants=true
tween(outer,{Size=UDim2.new(1,0,0,-4)},0.22,Enum.EasingStyle.Quint)task.delay(0.24,function()outer:Destroy()end)end)end
task.delay(duration,dismiss)closeButton.MouseButton1Click:Connect(dismiss)table.insert(self._toasts,dismiss)while #self._toasts>self.MaxNotifications do
local oldest=table.remove(self._toasts,1)oldest()end
return{Dismiss=dismiss}end
function Window:Destroy()if self._destroyed then
return
end
self._destroyed=true
for flag,element in pairs(Library.Flags)do
if element._window==self then
Library.Flags[flag]=nil
end
end
if self._persistentRegistry then
local entry=self._persistentRegistry[self._registryName]if entry and entry.Window==self then
self._persistentRegistry[self._registryName]=nil
end
end
for element in pairs(self._elements or{})do
for _,disconnect in ipairs(element._listeners or{})do
pcall(disconnect)end
element._listeners={}end
self._elements={}local sectionTargets=self._sectionHoverTargets
if sectionTargets then
for index=#sectionTargets,1,-1 do
local target=sectionTargets[index]if target then
target.Update(false)end
end
table.clear(sectionTargets)end
if self._openDropdown and self._openDropdown.SetOpen then
self._openDropdown:SetOpen(false)end
self._openDropdown=nil
if self.Gui then
for _,object in ipairs(self.Gui:GetDescendants())do
if object:GetAttribute("JinHubDropdownPopup")then
object:Destroy()end
end
end
for index,entry in ipairs(Library.Windows)do
if entry==self then
table.remove(Library.Windows,index)break
end
end
for _,connection in ipairs(self._connections)do
connection:Disconnect()end
self._connections={}for _,listeners in pairs(self._inputListeners)do
table.clear(listeners)end
self._frameSteps={}self._controls={}self._toasts={}self.Tabs={}self.CurrentTab=nil
tween(self.Scale,{Scale=0.9},0.2)tween(self.Body,{GroupTransparency=1},0.2)tween(self.BodyStroke,{Transparency=1},0.12)tween(self.Shadow,{ImageTransparency=1},0.2)task.delay(0.22,function()self.Gui:Destroy()end)end
return Library
