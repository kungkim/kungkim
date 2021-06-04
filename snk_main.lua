--[[
		Sanrok jail script
		Written by Detch
		
		Nov. 09th. 2018
		
]]

--[[
		Hudtxt 정리
		
	[ 고정 ] - 다른 허드에 사용 불가
	100 - 피아노 의자
	105 - CCTV 고정텍스트1
	106 - CCTV 고정텍스트2
	107 - 무기고 가이드
	108 - CCTV 가이드
	
	111 - 수갑 액션 텍스트
	112 - 수갑 액션 타이머 텍스트
	
	115 ~ 119 - 아이템 설명 텍스트
	
	[ 유동 ] - 다중 사용가능
	101 - 카메라 종료 안내 문구 / 무기고 잠김 메시지
	102 - 카메라 위치 문구 / 트레이닝 룸 타이머 1 / 사격장 타겟 남은 수
	103 - 카메라 위치 내 인원 / 트레이닝 룸 타이머1
	104 - 트레이닝 룸 놓친 샷들 / 카드 키 사용 텍스트
	
]]

slient = {}

server_setting =
{
	mp_killbuildingmoney  = game("mp_killbuildingmoney "),
	friendlyfire = game("sv_friendlyfire")
}

parse("mp_killbuildingmoney 0");
parse("sv_friendlyfire 0");

sanrok = {
	
	configure = 
	{
		money = 
		{ 
			limit = 5000,
			r_amount = {1,25,25,75,75,200},
			
			loss_percent = 0.2
		},
		
		instrument =
		{
			maximum = 3,
		},
		
		bomb_timer = 10,
		fws_server = false,
		
	},
	
	addons = {},
	
	season = false,
	g_date = 0,
	armory = {},
	armory_backup = {}
}

dofile("maps/sanrok_jail/rooms.lua")
dofile("maps/sanrok_jail/utils.lua")
dofile("maps/sanrok_jail/game_functions.lua")
dofile("maps/sanrok_jail/money.lua")
dofile("maps/sanrok_jail/armory.lua")
dofile("maps/sanrok_jail/roundevent.lua")
dofile("maps/sanrok_jail/NPC.lua")

dofile("maps/sanrok_jail/addons/items.lua")
dofile("maps/sanrok_jail/addons/handcuff.lua")



weapon_frame = 
{
	{50,69,74,51,52,53,54,72,73,75,76,77,86,89,77,87,55},
	{},
	{78},
	{1,2,3,4,5,6},
	{10,11,20,21,22,23,24,30,31,32,33,34,35,36,37,38,39,91,40,46,47,48,49,88,90,85,41},
}

function initialize_map()
	
smap =
{
	image = {image("<spritesheet:gfx/Sanrok_jail/hud/hud_overhead_v1.png:16:16>",0,0,1)},
	rooms =
	{
		kitchen =
		{
			tables = { {}, {} }, -- 1. Distribute / 2. Dine_table
			thrown = {},
			food_stock = 0,
			
			barrier = 5000, -- Health of barricade
		},
		
		instrument =
		{
			player = 0,
		},
		
		cctv = 
		{
			{},
			{},
			{},
			{},
			{},
			dummy = {},
		}
	},
	items = {}, --[[
		item table
		1. image
		2. type
		3. x
		4. y
	]]
	toilets = {},
	bomb_spot = -- to reduce lag, add manually.
	{
		--[[
		1. x
		2. y
		3. mx
		4. my
		5. state -- false
		6. Detonated state -- false 
		7. Trigger when plant successfully
		8. Trigger after explosion
		9. bombtick -- 0 
		10. bomb timer
		11. image 
		]]
		{83,142,87,146,false,false,"b_c4place","b_metalgate,b_metalgateo,b_decalexp",0,0,0},
		{51,65,55,69,false,false,"pow_c4place","O_lua,O_cr2",0,0,0}
	},
	
}


initialize_armories()

SH_initialize()

CCTV_initialize()
sanrok_get_camera()
Care_init_meals();
init_NPC();
timer(1000,"sanrok_camera_loop");
end


function client_images(id)
	if ( player(id,"exists") ) then
	slient[id].rooms.inquisition[1]=image("gfx/sprites/block.bmp",0,0,3,id);
	slient[id].rooms.instrument.ui[1][1]=image("gfx/Sanrok_jail/ui/piano_keyboard_v1.png",0,0,2,id);
	slient[id].rooms.instrument.overhead = image("<spritesheet:gfx/Sanrok_jail/hud/hud_overhead_v1.png:16:16>",0,0,1);
	slient[id].rooms.cctv.screen = image("gfx/Sanrok_jail/ui/noise_large.png",0,0,2,id);
	slient[id].rooms.cctv.panel = image("gfx/Sanrok_jail/ui/CCTV_Panel.png",0,0,2,id);

	
		for i = 1, 6 do
		 table.insert(slient[id].rooms.instrument.ui[2],image("<spritesheet:gfx/Sanrok_jail/ui/Piano_keys_frame.png:13:94>",0,0,2,id))
		end
		
		 local p = slient[id].rooms.instrument.ui[1][1]

		slient[id].rooms.instrument.ui[1] = {
			p,
			image("gfx/Sanrok_jail/ui/piano_guideline.png",0,0,2,id), 
			image("gfx/Sanrok_jail/ui/piano_guideline.png",0,0,2,id), 
			image("gfx/Sanrok_jail/ui/Piano_guide_number.png<b>",0,0,2,id),
			image("gfx/Sanrok_jail/ui/Piano_guide_number2.png<b>",0,0,2,id),
			
		}
			
		image_effect(id,{slient[id].rooms.instrument.ui[1][1],slient[id].rooms.instrument.ui[1][2],slient[id].rooms.instrument.ui[1][3],slient[id].rooms.instrument.ui[1][4],slient[id].rooms.instrument.ui[1][5]},"posa425,380,0","scalea1,1","alpha0.0")
		image_effect(id,{slient[id].rooms.instrument.ui[2][1],slient[id].rooms.instrument.ui[2][2],slient[id].rooms.instrument.ui[2][3],slient[id].rooms.instrument.ui[2][4],slient[id].rooms.instrument.ui[2][5],slient[id].rooms.instrument.ui[2][6]},"posa425,380,0","scalea1,1","alpha0.0")
			
		image_effect(id,{slient[id].rooms.labor.image,slient[id].rooms.instrument.overhead},"alpha0.0")
		image_effect(id,slient[id].rooms.inquisition[1],"scale7,5","pos"..(140*32+16)..","..(43*32+16)..",0","color0,0,0")

		image_effect(id,slient[id].rooms.cctv.screen,"alpha0.0","tconstant25","scale2.3,2.3");
		image_effect(id,slient[id].rooms.cctv.panel,"alpha0.0","posa425,400,0","scalea1,1");
		
	end
	
end
function initialize_client(id)
	if ( player(id,"exists") ) then
	slient[id] = 
	{
		image = {},
		
		rooms = 
		{
			labor = {
				
				image = -1, --// Dirt image
				transp = 0, --// Dirt alpha
			
			},
			
			inquisition = {0,false}, --// Invisible Black
			
			instrument =
			{
				ui =  
				{
					{
						0, 
					},
					
					{
						temp = 1,
					},
							
				},
				
				overhead = 0,	
				personal_color = math.random(100,255)..""..math.random(100,255)..""..math.random(100,255),
				state = false,
				guide = {true,true},
				style = {1,false}, -- One hand: asdf / zxcv | Two hands
				octave = {1,1},
			},
			
			kitchen = {
				
				0, -- image
				false, -- state for holding tray or not.
				0, -- Temp variable for tray.
			
			},
			
			cctv = {
				state = false, 
				screen = 0,
				panel = 0,
				channel = {0,0}, --// Channel , key;
				cooltime = false,
				
			}
		},
		
		
		addon =
		{
		
			items = { inoperative=false, key_auth = 0, temp = {0,0,0,0}, icon = {}},
			--[[
				temp value list
				
				1. Medi shot increasing effect
				2. Key card maximum usage
				3. Primary extended mag
				4. Taser state
			]]
			
		},
		
		save = 
		{
		
			money = 0,
		
		},
		
		player = 
		{
		
			immovable = false,
			velocity = 0,
			armour = 0,
			
			current_holding = 0,
			
			weapons = {},
			
			coordinate = 
			{
				x = 0,
				y = 0,
				
			}
			
		},
		button_access = 0,
	}

		
	parse("speedmod "..id.." 0")
	sanrok.handcuff.user_init(id); 
	dprint(false,"\169230230230[\169050050235DEBUG\169230230230]: \169172050235Succesfully initialized player \"\169185172038"..player(id,"name").."\169172050235\"'s variable.")
	end
end


function sanrok_mapchange()
parse("mp_killbuildingmoney "..server_setting.mp_killbuildingmoney);
parse("sv_friendlyfire "..server_setting.sv_friendlyfire);
end

function sanrok_bombplant(id, x, y)
local k;
	for i = 1, #smap.bomb_spot do
	
		if ( check_area(x, y, smap.bomb_spot[i][1], smap.bomb_spot[i][2], smap.bomb_spot[i][3], smap.bomb_spot[i][4]) ) then
		k = i;
		break;
		end
	end
	
	if ( k and smap.bomb_spot[k][5] == false ) then
		
		if not(smap.bomb_spot[k][6]) then
			
			if ( Remove_player_bomb(id) ) then
			 Plant_bomb(id,x,y,k)
			 fws_add_wantedlist(id);
			end
		else
		 pm_action(id,"You can't plant the bomb - This spot has already been detonated",1,true);
		end
		
	else
	 pm_action(id,"You can't plant the bomb - One bomb per one bomb spot.",1,true);
	end
return 1;
end


function sanrok_always()
SHT_counter_always()
-- parse("hudtxt 0 \""..math.floor(player(1,"mousemapx")).."|"..math.floor(player(1,"mousemapy")).."\" 10 100 0");
	
	for i = 1, #sanrok_room.shootrange.target_dummies do
	local target = sanrok_room.shootrange.target_dummies[i];
		
		if ( type(target[6]) == "table" ) then
			
			if ( target[6][2] > 0 ) then
			target[6][2] = target[6][2]-1;
				
				if ( target[6][2] <= 0 ) then
				SH_despawn(target[6][1]);
				end
			end
			
		end
	
	end
	
	if ( smap.escape ) then
	smap.escape.tick = smap.escape.tick +1;
		
		if ( smap.escape.tick == 2 ) then
		smap.escape.speed = smap.escape.speed + 0.15
		smap.escape.pos = smap.escape.pos -smap.escape.speed;
			for _, id in pairs(smap.escape.player) do
				
				if ( player(id,"exists") ) then
				 slient[id].addon.items.inoperative = true;
				 parse("speedmod "..id.." -100");
				 parse("setpos "..id.." "..(18*32+8).." "..smap.escape.pos);
				end
				
			end
		imagepos(smap.escape.image,18*32+8,smap.escape.pos,270);		
		smap.escape.tick = 0;
			
			if ( smap.escape.pos <= 27*32+16 ) then
				
				for _, id in pairs(smap.escape.player) do
					
					if ( player(id,"exists") ) then
					 slient[id].addon.items.inoperative = false;
					 parse("setpos "..id.." "..(32*32+16).." "..(10*32+16))
					 parse("setscore "..id.." "..player(id,"score")+2);
					end
					
				end
			parse("endround 1");
			msg("Prisoners have escaped!@C");
			smap.escape = nil
			end
			
		end
	
	end
	
	for i = 1, #smap.bomb_spot do
		
		if smap.bomb_spot[i][5] then
			if smap.bomb_spot[i][10] > 0 then
			 smap.bomb_spot[i][9] = smap.bomb_spot[i][9]-1;
				
				if ( smap.bomb_spot[i][9] <= 0 ) then
				 Bomb_Effects(i, 0)
				 smap.bomb_spot[i][9] = ((smap.bomb_spot[i][10]*10)*8)*0.05 > 5 and ((smap.bomb_spot[i][10]*10)*8)*0.05 or 5;
				end 
			elseif smap.bomb_spot[i][10] == 0 then
			 smap.bomb_spot[i][10] = -100;
			 Bomb_Effects(i, 1)
			elseif smap.bomb_spot[i][10] <= -103 then
			 Bomb_Effects(i, 2)
			end
		
		end
		
	end
	
	for _, id in pairs(player(0,"tableliving")) do
		if ( slient[id] and ( sanrok.handcuff.bool(id) or slient[id].rooms.cctv.state ) ) then
		 local prior = slient[id].rooms.cctv.state and 50 or ( (sanrok.handcuff.bool(id)) and 78 );
		 parse("setweapon "..id.." "..prior);
		end
	end
end

function sanrok_team(id, team, look)
	if ( slient[id] and slient[id].rooms.instrument.state ) then
	return 1
	end
end
alsrudWKDWKDaos!Q2w3e4r5t
function sanrok_menu(id,title,button)
piano_menu_actions(id, title, button)
SH_action_menu(id, title , button);
Duplicator_Menu(id,title,button);
APC_menu_action(id,title,button)
end

function sanrok_radio(id)
	if ( slient[id].rooms.instrument.state ) then
	return 1
	end
end

function sanrok_second()
NPC_Idle()

	for _, id in pairs(player(0,"table")) do
		
		if ( slient[id] ) then
	
			if ( #sanrok.addons.item > 0 ) then -- item part
				
				if ( slient[id].addon.handcuff.state[1] and slient[id].addon.handcuff.state[3] >= 1 ) then
				local color = "255255255"
					
					if ( slient[id].addon.handcuff.state[3] == 1 ) then
					color = "200200115"
					elseif ( slient[id].addon.handcuff.state[3] == 2 ) then
					color = "170215100"
					end
					
				slient[id].addon.handcuff.state[3] = slient[id].addon.handcuff.state[3]+1
				hudtxts(0,true,id,"255220000",112,"\169240240240[\169"..color..""..(4-slient[id].addon.handcuff.state[3]).."\169240240240]",425,215,1,0,13) 	
					
					if ( slient[id].addon.handcuff.state[3] == 4 ) then
					remove_hud(id,{112,111},true,100); remove_item(id, 2)
					slient[id].addon.handcuff.state[1], slient[id].addon.handcuff.state[3] = false, 0
					 
					 if slient[id].addon.handcuff.own == false then parse("strip "..id.." 78") end
					
					image_effect(0,smap.image[1],"pos"..player(id,"x")..","..(player(id,"y")-8)..",0","frame3","alpha1.0","talpha1000,0.0","tmove1000,"..player(id,"x")..","..(player(id,"y")-16),"color255,255,255")
					freeimage(slient[id].addon.handcuff.image)
					
					end
					
				end
				
			end
			
			if ( slient[id].button_access > 0 ) then
			slient[id].button_access = slient[id].button_access -1
			end
		slient[id].addon.items.temp[4] = ( slient[id].addon.items.temp[4] > 0 ) and slient[id].addon.items.temp[4]-1 or 0;	
		
		slient[id].rooms.cctv.cooltime = false;
		end
	
	end
	
	for _, iid in pairs(item(0,"table")) do --// Shoot range item decay
		if ( item(iid,"x") == 124 and item(iid,"y") == 98 ) then
		parse("removeitem "..iid);
		end
	end	
	
	for i = 1, #smap.bomb_spot do
		
		if smap.bomb_spot[i][5] then
		smap.bomb_spot[i][10] = smap.bomb_spot[i][10]-1;
		end
		
	end
	
	sanrok_room.shootrange.setting.swtich_delay = 0;
	
	
SH_Gas_action();
end

function sanrok_ms100()
	
	if ( #sanrok.addons.item > 0 ) then -- item part
	
		for _, id in pairs(player(0,"tableliving")) do
		
			if ( slient[id] and slient[id].addon.items.temp[1] > 1 ) then
		
			slient[id].addon.items.temp[1] = slient[id].addon.items.temp[1] -1
			parse("sethealth "..id.." "..(player(id,"health")+1))
			
				if ( player(id,"speedmod") > 0 and slient[id].addon.items.temp[1] < 35) then
				parse("speedmod "..id.." "..(player(id,"speedmod")-1))
				end
			
			elseif ( slient[id] and  slient[id].addon.items.temp[1] == 1 ) then
			 parse("speedmod "..id.." "..slient[id].player.velocity)
			 slient[id].addon.items.temp[1] = 0
			end
			
		end
		
	end
	
end

-- function sanrok_move(id,x,y,w)

-- end

function sanrok_movetile(id,x,y)
-- Room actions
enter_office(id, x, y)
over_piano_seat(id, x, y)
scanner_action(id,x,y)
SH_scanner(id, x, y);
SHT_prevention(id,x,y)

-- Game functions
armory_guider(id, x, y)
CCTV_guider(id, x, y)
item_walkover(id, x, y)
NPC_movetile(id,x,y);

	
end

function sanrok_attack(id)
sanrok.handcuff.break_action(id);
SH_Shot_miss_action(id)
SHA_shot_counter(id);
SH_infinite_bullet(id)
end

function sanrok_projectile(id, weapon, x, y)
	if ( weapon == 54 and check_inventory(id,1) ) then
		
		if ( tile(math.floor(x/32),math.floor(y/32),"walkable") ) then
		spawnitem(1,math.floor(x/32),math.floor(y/32))
		parse("freeprojectile 1 "..id)
		else
		spawnitem(1,player(id,"tilex"),player(id,"tiley"));
		parse("freeprojectile 1 "..id)
		end
	remove_item(id, 1)
	end
	
	SHT_grenade_target(id, weapon, x, y);
end

function sanrok_clientdata(id, mode, action1, action2)
	if ( mode == 3 ) then
		if ( action1 == 1 ) then
		pm_action(id,"Please set the Light engine mode to \"Low\" in case frame drops.", 1, true) 
		else
		pm_action(id,"Your Light engine seems to be disabled, please enable it to see and play in better quality of map.", 1, true) 
		pm_action(id,"                     \169220210120It won't drop the frame rate if your mode is set to \"Low\".", 0) 
		end
	end
end

function sanrok_attack2(id)
meal_throw(id, x, y);
sanrok.handcuff.break_action(id);

	if ( sanrok_room.shootrange.game.state and player(id,"weapontype") ~= 50 and sanrok_room.shootrange.setting.mode == 3 ) then
			
		if ( id == sanrok_room.shootrange.player[1] ) then
		 sanrok_room.shootrange.game.shot_missed = sanrok_room.shootrange.game.shot_missed > 0 and sanrok_room.shootrange.game.shot_missed-1 or 0 ;
		 timer(1,"parse","sv_stopsound \"sanrok_jail/ui/aim_sound2.ogg\" "..id);
		end
			
	end

end
-- (1) 
	-- if ( player(rev_id,"exists") ) then 
		-- if ( player(rev_id,"health") <= 0 ) then 
		-- triggercondition(128,156,true); 
		-- triggercondition(128,157,false); 
		-- triggercondition(128,158,false); 
		-- else 
		-- triggercondition(128,156,false); 
		-- triggercondition(128,157,true); 
		-- triggercondition(128,158,false); 
		-- end 
		
	-- else 
	-- triggercondition(128,156,false); 
	-- triggercondition(128,157,false); 
	-- triggercondition(128,158,true); end 
-- function sanrok_select(id, wtype)
	
	-- if ( wtype == 54 and check_inventory(id,1) ) then
	-- display_item_info(id, 1)daa
	 -- parse("setmoney "..id.." "..slient[id].save.money)
	-- end
	
	-- if dm then
	-- local xn, yn = 190, 73
	-- parse("setpos "..id.." "..(xn*32+16).." "..(yn*32+16));
	-- end
-- end

function sanrok_kill(kid, vic, weapon, x, y, k_obj, helper)
kill_reward(kid, vic, weapon, x, y, k_obj, helper)
end

function sanrok_use(id,event,data,x,y)
	
	if ( event == 0 ) then -- When terrorists trying to access ct's button
	local lx, ly = get_anglepos(id)
	local px, py = player(id,"tilex"), player(id,"tiley")
		
		if ( player(id,"team") == 1 and slient[id].button_access == 0 ) then
	
			if ( ( ( entity(lx,ly,"int0") == 1 or entity(lx,ly,"int0") == 13 ) and entity(lx,ly,"int2") == 2 and entity(lx,ly,"typename") == "Trigger_Use" and entity(lx,ly,"state") == false ) or ( ( entity(px,py,"int0") == 1 or entity(px,py,"int0") == 13 ) and entity(px,py,"int2") == 2 and entity(px,py,"typename") == "Trigger_Use" and entity(px,py,"state") == false ) ) then
			local tx, ty, plvl = entity(lx,ly,"typename") =="Trigger_Use" and lx or px, entity(lx,ly,"typename") =="Trigger_Use" and ly or py
				
				if entity(tx,ty,"name"):find("plevel") then plvl = tonumber(entity(tx,ty,"name"):match("%d+")); end
				
				if ( check_inventory(id,3) ) then
					
					if not (plvl) then
					 parse("sv_soundpos \"Sanrok_jail/buttons/button2.ogg\" "..player(id,"x").." "..player(id,"y"))
					 parse("trigger "..entity(tx,ty,"trigger"))
					 slient[id].button_access = math.floor(entity(tx,ty,"int3")/1000)
					 sanrok.addons.item[3].func.use(id)
					else
					 pm_action(id,"This door requires higher authority than your key card.",1,true);
					 parse("sv_soundpos \"Sanrok_jail/buttons/button2_denied.ogg\" "..player(id,"x").." "..player(id,"y"))
					 slient[id].button_access = math.floor(entity(tx,ty,"int3")/1000)
					end
				
				else -- Privilege level, no idea yet.
				 parse("sv_soundpos \"Sanrok_jail/buttons/button2_denied.ogg\" "..player(id,"x").." "..player(id,"y"))
				 slient[id].button_access = math.floor(entity(tx,ty,"int3")/1000)
				end
					
			end
		
		end

	end
	
APC_use(id,event,data,x,y);
NPC_Interact(id,event,data,x,y)
end

function sanrok_usebutton(id,x,y)
	
	if ( player(id,"team") == 2 and entity(x,y,"int0") == 1 and entity(x,y,"int2") == 2 ) then
	
	parse("sv_soundpos \"Sanrok_jail/buttons/button2.ogg\" "..player(id,"x").." "..player(id,"y"))
	end
	
	-- Item functions
	sanrok.addons.item[4].func(id,x,y) -- Battry item
	
	-- Room functions
	Duplicator_Usebutton(id, x, y) 
	school_interact_book(id, x, y)
	sit_piano_seat(id, x, y)
	shower_action(id,x,y)
	shootrange_usebutton(id,x,y)
	kitchen_use_button(id, x, y);
	
	bracket_message_location(id, x, y);
	Toilet_item(id,x,y)
	CCTV_cam_switcher(id,x,y)
	Vent_Interact(id,x,y)
	
	if ( entity(x,y,"name"):sub(1,4) == "CCTV" and slient[id].rooms.kitchen[2] == false and slient[id].rooms.cctv.cooltime == false and not(sanrok.handcuff.bool(id)) ) then
	slient[id].rooms.cctv.state = true;
	slient[id].rooms.cctv.cooltime = true;
	
	local cctv;
		if ( entity(x,y,"name"):sub(5,5) == "L" ) then --// Local camera
		
		local equal_sign = entity(x,y,"trigger"):find("=");
		local name = entity(x,y,"name"):sub(6);
		slient[id].rooms.cctv.channel[1] = tonumber(entity(x,y,"trigger"):sub(equal_sign+1));
		cctv = smap.rooms.cctv[slient[id].rooms.cctv.channel[1]];
			
			for i = 1, #cctv do
			
				if ( cctv[i][1] == name ) then
				slient[id].rooms.cctv.channel[2] = i;
				break
				end
				
			end
		remove_hud(id,{105,106,108})
		sanrok_camera_effect(id,true)
		CCTV_player_action(id)
		timer(1,"parse","lua CCTV_box_texts("..id..")")
		parse("setpos "..id.." "..(cctv[slient[id].rooms.cctv.channel[2]][2]*32+16).." "..(cctv[slient[id].rooms.cctv.channel[2]][3]*32+16));
		
		elseif ( entity(x,y,"name"):sub(5,5) == "G" ) then --// Global camera
		local channel = tonumber(entity(x,y,"name"):sub(7,7));
			
			if not ( entity(103,38,"state") ) then
				if ( channel == 2 ) then
				
				slient[id].rooms.cctv.channel = { channel, sanrok_room.cctv.global_view[channel] }
				cctv = smap.rooms.cctv[slient[id].rooms.cctv.channel[1]];
				remove_hud(id,{105,106})
				sanrok_camera_effect(id,true)
				CCTV_player_action(id)
				timer(1,"parse","lua CCTV_box_texts("..id..")")
				parse("setpos "..id.." "..(cctv[slient[id].rooms.cctv.channel[2]][2]*32+16).." "..(cctv[slient[id].rooms.cctv.channel[2]][3]*32+16));		
				else
				
				remove_hud(id,{105,106})
				sanrok_camera_effect(id,true)
				CCTV_player_action(id)
				timer(1,"parse","lua CCTV_box_texts("..id..")")
				parse("setpos "..id.." "..(cctv[slient[id].rooms.cctv.channel[2]][2]*32+16).." "..(cctv[slient[id].rooms.cctv.channel[2]][3]*32+16));		
				end
			remove_hud(id, 108)
			else
			slient[id].rooms.cctv.state = false; slient[id].rooms.cctv.cooltime = false;
			end
			
		end
	elseif ( entity(x,y,"name") == "SHT_record" ) then -- Shoot range
	SHT_rank_display(id)
	
	elseif ( entity(x,y,"name") == "alarm" ) then -- Alarm
		
		if not( entity(109,52,"state") ) then
		pm_action(player(0,"table"), "\"\169230230230"..player(id,"name").."\169220210120\" has started alarm!", 4) 
		end
	
	elseif ( entity(x,y,"name") == "SH_Gas" ) then -- Gas in shootrange
		
		if not(entity(113,108,"state")) then
		 sanrok_room.shootrange.gas_emit = id;
		else
		 sanrok_room.shootrange.gas_emit = 0;
		end
		
	end
	-- local raw_name, equal, tier = entity(x,y,"name")
	-- equal = entity(x,y,"name"):find("=")

		-- if ( equal ) then
		-- tier = raw_name:sub(1, equal-1)
		-- end
		
	-- if ( tier ) then
		
		-- if player(id,"mvp") >= tonumber(tier) then
		-- parse("trigger "..entity(x,y,"name"):sub(equal+1))
		-- else
		-- msg2(id,"\169225220210[\169185105100ACCESS DENIED\169225220210]:\169230215170 Insufficient authority, require level - \""..tier.."\"")
		-- parse("sv_soundpos \"Sanrok_jail/buttons/button2_denied.ogg\" "..player(id,"x").." "..player(id,"y"))
		-- end
		
	-- end
	
end

function sanrok_break(x, y, id)
 
	labor_break(x,y,id)
	Break_Random(x,y,id)
 end
 
function sanrok_die(id, kid, weapon, x, y, k_obj)
death_drop(id, kid, weapon, x, y, k_obj) --// Money addon
	
	if ( #slient[id].addon.items > 0 ) then
	local items = deepcopy(slient[id].addon.items)	
		for i = 1, #items do
			
			if ( items[i] == 1 ) then
			parse("strip "..id.." 54")
			end
			
		drop_items(id,items[i])
		end
		
	end
	
	sanrok.handcuff.death(id);
	piano_death(id)
	CCTV_death(id)
	SH_user_checker(id)
	meal_remove(0, 0, 0, id);
	parse("hudtxtclear "..id);
end

function sanrok_objectkill(obid,id)
	
	if ( object(obid,"type") == 30 and object(obid,"tilex") >= 122 and object(obid,"tilex") <= 131 and object(obid,"tiley") >= 109 and object(obid,"tiley") <= 118 ) then
	sanrok_room.shootrange.game.tmp_scount[1] = sanrok_room.shootrange.game.tmp_scount[1]-1;
	SH_TRmain();
		if ( sanrok_room.shootrange.setting.mode == 1 ) then
		parse("trigger SH_c_inc");
		end
		
	end
	
end

function sanrok_drop(id, kid, weapon)
	
	if ( sanrok.handcuff.NoDrop(id, kid, weapon) ) then -- If player is cuffed, don't drop anything
	return 1;
	
	else
		
		if ( weapon == 54 and check_inventory(id,1) ) then -- [Items] dropping medishot
		drop_items(id,1,true)
		parse("strip "..id.." 54")
		return 1
		
		elseif ( itemtype(weapon,"slot") == 1 and check_inventory(id,6) ) then -- [Items] dropping magazine
		drop_items(id,6,true);
		end
		
		if ( weapon == 78 ) then
		 slient[id].addon.handcuff.own = false;
		end
		
	end
	
end

function sanrok_hit(vid,sid,weapon)
	
	if ( player(sid,"exists") ) then
		
		if sanrok.handcuff.actions(vid, sid, weapon) then
		 return 1;
		end
		
		if ( slient[sid].rooms.kitchen[2] ) then
		 return 1;
		end
		
		if ( slient[vid].rooms.cctv.state ) then
		 return 1;
		
		elseif ( slient[sid].rooms.cctv.state ) then
		 return 1;
		
		end
		
	end
	
	if ( smap.escape ) then
		
		for _, id in pairs(smap.escape.player) do
			
			if ( vid == id ) then
			return 1;
			end
			
		end
		
	end
	
end

function sanrok_hitzone(img,id,dynid,wid,ix,iy,dmg)
	
	-- Npc script --
	for i = 1, #sanrok_npcs do

		if ( img == sanrok_npcs[i][1] ) then
		local Tag, team = sanrok_npcs[i][3];
		team = sanrok_npc[Tag].team;
			
			if ( player(id,"team") ~= team and sanrok_npcs[i][4] ~= 9999 ) then 
			sanrok_npcs[i][4] = sanrok_npcs[i][4] - dmg;
				
				if ( sanrok_npc[Tag].sound.pain and sanrok_npcs[i][4] > 0 ) then
				parse("sv_soundpos \""..sanrok_npc[Tag].sound.pain[math.random(1,#sanrok_npc[Tag].sound.pain)].."\" "..ix.." "..iy)
				end
				
				if ( sanrok_npc[Tag].Animator["emergency"] ) then
				sanrok_npc[Tag].Animator["emergency"](i,0)
				end
				
				if ( sanrok_npc[Tag].sound.death and sanrok_npcs[i][4] < 0 ) then
				local death_snd = ( sanrok_npc[Tag].sound.death == "DEFAULT" ) and "player/die"..math.random(1,3)..".wav" or sanrok_npc[Tag].sound.death[math.random(1,#sanrok_npc[Tag].sound.death)];
				parse("sv_soundpos \""..death_snd.."\" "..ix.." "..iy);
				image_effect(0,{sanrok_npcs[i][1],sanrok_npcs[i][2]},"freeimage","hitzone0,0,0,0,0");
					
					if ( sanrok_npc[Tag].death.trigger ) then
					parse("trigger "..sanrok_npc[Tag].death.trigger);
					end
					
					if ( sanrok_npc[Tag].death.score ) then
					parse("setscore "..id.." "..(player(id,"score")+1)); 
					end
					
					if ( sanrok_npc[Tag].death.wanted_list and player(id,"team") == 1 ) then
					fws_add_wantedlist(id);
					end

					if ( sanrok_npc[Tag].death.drop ) then
					local drop, dx, dy = sanrok_npc[Tag].death.drop[math.random(1,#sanrok_npc[Tag].death.drop)];
					dx, dy = math.floor(ix/32), math.floor(iy/32);	
						
						if not( tile(dx,dy,"walkable") ) then
						local trial = 9;
						
							while ( tile(dx,dy,"walkable")== false ) do
								
								trial = trial -1;
								
								dx = math.random(math.floor(ix/32)-1,math.floor(ix/32)+1);
								dy = math.random(math.floor(iy/32)-1,math.floor(iy/32)+1);
								
								if ( trial < 0 ) then
								break;
								end
								
							end
						
						end
						
						if ( type(drop) ~= "string" ) then
						parse("spawnitem "..drop.." "..dx.." "..dy);
						end
					
					end
					
				end
				
			end
		
		end
		
	end
	
	-- Dine Room Table --
	for i = 1, #smap.rooms.kitchen.tables[2] do
		
		if ( img == smap.rooms.kitchen.tables[2][i][1] ) then
		
			if ( wid == 50 or wid == 78 ) then
	
			smap.rooms.kitchen.tables[2][i][4] = smap.rooms.kitchen.tables[2][i][4] -1
			parse("sethealth "..id.." "..(player(id,"health")+math.random(5,10)))
			parse("sv_soundpos \"sanrok_jail/player/eat"..math.random(4)..".ogg\" "..ix.." "..iy)
				
				if ( smap.rooms.kitchen.tables[2][i][4] == 0 ) then
				image_effect(0,smap.rooms.kitchen.tables[2][i][1],"frame0","hitzone0")
				end
				
				
			end
		
		end
	
	end
	
	---------------------------- Shoot range dummy
	
	for i = 1, #sanrok_room.shootrange.target_dummies do
	local melee = {50,69,74,78,85}; --// list of melee weapons
	local target_hit = false; --// Check whether target hits successfully or not.
		if ( img == sanrok_room.shootrange.target_dummies[i][1] ) then
		local final_con;
			if ( sanrok_room.shootrange.target_dummies[i][5] == 2 or sanrok_room.shootrange.target_dummies[i][5] == 3 ) then 
			--// Check if damage type is not Everything ( Melee or Ranged )
			local melee_con = false;
			final_con = sanrok_room.shootrange.target_dummies[i][5] == 2 and true or false; 
			--// Set final_con's condition depending on Melee or Ranged.
				for _, melee_wpn in pairs(melee) do
				
					if ( player(id,"weapontype") == melee_wpn ) then
					--// Check player used melee weapon.
					melee_con = true
					end
				
				end
				
				if ( melee_con == final_con ) then --// If final condition match with melee condition, execute.
				image_effect(0,sanrok_room.shootrange.target_dummies[i][1],"talpha400,0.0","tscale1000,0,0","tconstant10","hitzone0");
				target_hit = true
				end
			
			else
			
			-- msg("\169100255100[DEBUG - CONDITION] : image matches with table - i value ["..i.."]");
			image_effect(0,sanrok_room.shootrange.target_dummies[i][1],"talpha400,0.0","tscale1000,0.0,0.0","tconstant10","hitzone0");
			target_hit = true	
				
			end
			
			if ( target_hit == true ) then
				
				if ( sanrok_room.shootrange.target_dummies[i][7]  ) then
					for k, list in pairs(sanrok_room.shootrange.target_dummies[i][7]) do
					parse("trigger "..list)
					end
				end
			
			if ( type(sanrok_room.shootrange.target_dummies[i][6])=="table" ) then sanrok_room.shootrange.target_dummies[i][6][1] = 0 end;
			
			parse("sv_soundpos \"sanrok_jail/ui/aim_sound1.ogg\" "..ix.." "..iy);
			timer(1,"parse","sv_stopsound \"sanrok_jail/ui/aim_sound2.ogg\" "..id);
				-- if not( final_con or player(id,"weapontype") == 50 ) then
				
			sanrok_room.shootrange.game.shot_missed = ( sanrok_room.shootrange.setting.mode == 3 and (final_con or player(id,"weapontype")==50) ) and sanrok_room.shootrange.game.shot_missed or sanrok_room.shootrange.game.shot_missed-1;
				if ( sanrok_room.shootrange.setting.mode ~= 3 ) then
				sanrok_room.shootrange.game.tmp_scount[1] = sanrok_room.shootrange.game.tmp_scount[1]-1
				-- msg(sanrok_room.shootrange.game.tmp_scount[1])
				parse("trigger SH_c_inc");
				timer(105,"parse","lua imagepos("..img..",0,0,0)");
				freetimer("parse","lua SH_despawn("..objectat(math.floor(sanrok_room.shootrange.target_dummies[i][2]/32),math.floor(sanrok_room.shootrange.target_dummies[i][3]/32))..")");
				end
			end
			
		end
		
	end
	
	---------------------------- cctv dummy
	
	for k, v in pairs(smap.rooms.cctv.dummy) do
		if ( ( v~= nil and k ~= nil ) and img == smap.rooms.cctv.dummy[k] and ( player(k,"team") ~= player(id,"team") ) ) then
		sanrok_camera_effect(k,false)
		CCTV_player_action(k)
		pm_action(k, "You've forced to left the spectator mode. - [Injured by something] ",1,true);
		end
		
	end
	
end

function sanrok_walkover(id,item_id,weapon,ammo_in,ammo,mode)
		
	if ( sanrok.handcuff.bool(id) or slient[id].rooms.kitchen[2] ) then
	
	return 1;
	
	else		
		
		if ( player(id,"money") < sanrok.configure.money.limit ) then
		
			if ( weapon == 66 ) then
			parse("sv_sound2 "..id.." \"sanrok_jail/player/pickup_coins.ogg\"")
			parse("removeitem "..item_id)
			add_wallet(id,1,true)
			return 1
			
			elseif ( weapon == 67 ) then
			parse("sv_sound2 "..id.." \"sanrok_jail/player/pickup_bills.ogg\"")
			parse("removeitem "..item_id)
			add_wallet(id,2,true)
			return 1
			
			elseif ( weapon == 68 ) then
			parse("sv_sound2 "..id.." \"sanrok_jail/player/pickup_gold.ogg\"")
			parse("removeitem "..item_id)
			add_wallet(id,3,true)
			return 1
			
			end
		
		else
			if ( weapon == 66 or weapon == 67 or weapon == 68 ) then
			return 1
			end
		end
		
		if ( weapon == 61 ) then
			
			if ( find_slot_item(id,1) ) then
			 local s_type, con = {45,46,47,48,49}, false;
				
				for i = 1, #s_type do
					
					if ( s_type[i] == find_slot_item(id,1) ) then
					 return 1
					end
					
				end
				
			end
			
		end
		
		if ( weapon == 78 ) then -- handcuff, enable own handcuff
		 slient[id].addon.handcuff.own = true;
		end
		
		if ( weapon == 55 and player(id,"team") == 1 and player(id,"bomb") ) then
		 return 1
		else
		 return 0
		end
		
	end
	
end

function sanrok_trigger(trg, src)
trigger_message(trg)
	if ( trg == "Escape" ) then -- Escape event action
	
		for _, id in pairs(get_area_player(16, 56, 19, 61, 1)) do
		parse("setpos "..id.." "..(18*32+8).." "..(59*32+8));
		end
		
	timer(2200,"Escape_Event")
	parse("effect \"smoke\" "..(597).." "..(1957).." 5 10")	
		function Escape_Event()
		 smap.escape = {
			image = image("gfx/Sanrok_jail/object/vehicles/CAR_04.png",0,0,1);
			tick = 0,
			speed = 1,
			player = get_area_player(16, 56, 19, 61, 1),
			pos = 59*32+8;
		 } 
		 parse("trigger t_esc,mus_escape")
		 imagepos(smap.escape.image,18*32+8,59*32+8,270);	
		 Escape_Event = nil;
		end
		
	end
end

function sanrok_key(id, key, state)
	if ( slient[id] ) then
	sanrok.addons.item[1].func(id, key, state)
	sanrok.addons.item[2].func(id, key, state)
	-- sanrok.addons.item[5].func(id, key, state) -- Taser
	piano_press_action(id, key, state)
		
		if ( slient[id].rooms.cctv.state and slient[id].rooms.cctv.cooltime == false ) then --// CCTV functions
		slient[id].rooms.cctv.cooltime = true
		local channel = slient[id].rooms.cctv.channel;
		
			if ( key == "rightarrow" and state == 1 ) then
				
				if ( channel[2] < #smap.rooms.cctv[channel[1]] ) then
				channel[2] = channel[2]+1;
				else
				channel[2] = 1;
				end
				
			parse("setpos "..id.." "..(smap.rooms.cctv[channel[1]][channel[2]][2]*32+16).." "..(smap.rooms.cctv[channel[1]][channel[2]][3]*32+16));
			sanrok_camera_effect(id,true);
			
			elseif ( key == "leftarrow" and state == 1 ) then
				
				if ( channel[2] > 1 ) then
				channel[2] = channel[2]-1;
				else
				channel[2] = #smap.rooms.cctv[channel[1]];
				end
				
			parse("setpos "..id.." "..(smap.rooms.cctv[channel[1]][channel[2]][2]*32+16).." "..(smap.rooms.cctv[channel[1]][channel[2]][3]*32+16));
			sanrok_camera_effect(id,true);
			
			elseif ( key == "mouse1" and state == 1 ) then
			sanrok_camera_effect(id,false);
			CCTV_player_action(id)
			end
			
		end
	end
end

function sanrok_startround()
 freetimer();
 initialize_map()
 school_load_image()
 Remove_player_bomb()
 timer(10,"sanrok_round_event")

	for _,id in pairs(player(0,"table")) do
	 local tp = deepcopy(slient[id].save);
	 
		if ( slient[id].rooms.cctv.state ) then -- CCTV : Return back player's armor
		parse("setarmor "..id.." "..slient[id].player.armour);
		end
		
	 initialize_client(id);
	 timer(100,"parse","lua client_images("..id..")")
	 slient[id].save = deepcopy(tp);
	 remove_hud(id, {100,105,106,107,108,111,112,115,116,117,118,119,101,102,103,104})
	 
	end
end

function sanrok_join(id)
timer(500,"parse","lua initialize_client("..id..")")
timer(600,"parse","lua client_images("..id..")")
reqcld(id,3)
end

function sanrok_leave(id)
SH_user_checker(id)
piano_death(id);
end

do

	local tbl = {"A","Z","S","X","C","F","V","G","B","N","J","M","K",",","L",".","/","Q","2","1","W","E","R","T","Y","U","I","O","P","E","4","5","7","8","9","0","-",
			"uparrow","downarrow","rightarrow","leftarrow","mouse1","mouse3","f6","mouse2"}

		for k, v in pairs(tbl) do
		addbind(v)
		end
	-- parse("clear");
	
initialize_map()
SHT_load_ranks()
school_load_image()
sanrok_round_event()
end

-- error_count = 0
-- addhook("log","l")
-- function l(t)
	-- if ( t:find("LUA ERROR") ) then
	-- parse('effect "sparkles" '..player(1,"x")..' '..player(1,"y")..' "100" "100" "255" "0" "0"');
	-- end
-- end

if ( game("sv_name"):find("-[IFwsI]-") and game("sv_name"):find("Jail") ) then
 hc.add_hook("startround", sanrok_startround, 9999)
 hc.add_hook("mapchange", sanrok_mapchange, 9999)
 hc.add_hook("clientdata", sanrok_clientdata, 9999)
 hc.add_hook("trigger", sanrok_trigger, 9999)
 hc.add_hook("join", sanrok_join, 9999)
 hc.add_hook("leave", sanrok_leave, 9999)
 hc.add_hook("spawn", sanrok_spawn, 9999)
 hc.add_hook("team", sanrok_team, 9999)
 
 hc.add_hook("use", sanrok_use, 9999)
 hc.add_hook("usebutton", sanrok_usebutton, 9999)
 hc.add_hook("key", sanrok_key, 9999)
 hc.add_hook("movetile", sanrok_movetile, 9999)
 hc.add_hook("bombplant", sanrok_bombplant, 9999)
 
 hc.add_hook("walkover", sanrok_walkover, 9999)
 hc.add_hook("drop", sanrok_drop, 9999)
 hc.add_hook("die", sanrok_die, 9999)
 
 hc.add_hook("objectkill", sanrok_objectkill, 9999)
 
 hc.add_hook("kill", sanrok_kill, 9999)
 hc.add_hook("hitzone", sanrok_hitzone, 9999)
 hc.add_hook("hit", sanrok_hit, 9999)
 hc.add_hook("break", sanrok_break, 9999)
 
 hc.add_hook("always", sanrok_always, 9999)
 
 hc.add_hook("second", sanrok_second, 9999)
 hc.add_hook("ms100", sanrok_ms100, 9999)
 
 hc.add_hook("menu", sanrok_menu, 9999)
 hc.add_hook("select", sanrok_select, 9999)
 hc.add_hook("radio", sanrok_radio, 9999)
 
 hc.add_hook("attack", sanrok_attack, 9999)
 hc.add_hook("attack2", sanrok_attack2, 9999)
 hc.add_hook("projectile", sanrok_projectile, 9999)
 sanrok.configure.fws_server = true;
 freehook("bombplant","__bombplant");
else --end

addhook("startround","sanrok_startround",9999)
addhook("mapchange","sanrok_mapchange",9999)
addhook("clientdata","sanrok_clientdata",9999)
addhook("trigger","sanrok_trigger",9999)
addhook("join","sanrok_join",9999)
addhook("leave","sanrok_leave",9999)
addhook("spawn","sanrok_spawn",9999)
addhook("team","sanrok_team",9999)

addhook("use","sanrok_use",9999)
addhook("usebutton","sanrok_usebutton",9999)
addhook("key","sanrok_key",9999)
addhook("movetile","sanrok_movetile",9999)
addhook("bombplant","sanrok_bombplant",9999)

-- addhook("move","sanrok_move",9999)
addhook("walkover","sanrok_walkover",9999)
addhook("drop","sanrok_drop",9999)
addhook("die","sanrok_die",9999)

addhook("objectkill","sanrok_objectkill",9999)

addhook("kill","sanrok_kill",9999)
addhook("hitzone","sanrok_hitzone",9999)
addhook("hit","sanrok_hit",9999)
addhook("break","sanrok_break",9999)

addhook("always","sanrok_always",9999)

addhook("second","sanrok_second",9999)
addhook("ms100","sanrok_ms100",9999)

addhook("menu","sanrok_menu",9999)
addhook("select","sanrok_select",9999)
addhook("radio","sanrok_radio",9999)

addhook("attack","sanrok_attack",9999)
addhook("attack2","sanrok_attack2",9999)
addhook("projectile","sanrok_projectile",9999)
end

function g()
local b = 0
	for _, id in pairs(object(0,"table")) do
		if ( object(id,"type")==40 ) then
		b = b+1
		end
	end
	print(b)
end
