local n1 = {
	offset      = -0.6,
	scale       = 1.5,
	spread      = {x = 600, y = 600, z= 600},
	seed        = 114,
	octaves     = 5,
	persistence = 0.6,
	lacunarity  = 2.0,
	flags       = "eased"
}

local n2 = {
	offset      = 48,
	scale       = 24,
	spread      = {x = 300, y = 300, z = 300},
	seed        = 907,
	octaves     = 4,
	persistence = 0.7,
	lacunarity  = 2.0,
	flags       = "eased"
}

local n3 = {
	offset      = -0.6,
	scale       = 1,
	spread      = {x = 250, y = 350, z = 250},
	seed        = 5333,
	octaves     = 5,
	persistence = 0.63,
	lacunarity  = 2.0,
	flags       = ""
}
local noise_b = minetest.get_mapgen_setting_noiseparams("mgv7_np_floatland_base") or n1
local noise_h = minetest.get_mapgen_setting_noiseparams("mgv7_np_float_base_height") or n2
local noise_m = minetest.get_mapgen_setting_noiseparams("mgv7_np_mountain") or n3
local floatland_y = minetest.get_mapgen_setting("mgv7_floatland_level") or 1280
local mount_height = minetest.get_mapgen_setting("mgv7_float_mount_height") or 128
local mount_dens = minetest.get_mapgen_setting("mgv7_float_mount_density") or 0.6

-- Based on these two funcs:
-- https://github.com/minetest/minetest/blob/28841961ba91b943b7478704181604fa3e24e81e/src/mapgen_v7.cpp#L415
-- https://github.com/minetest/minetest/blob/28841961ba91b943b7478704181604fa3e24e81e/src/mapgen_v7.cpp#L428

local function spawn_point()
	local noise_base = minetest.get_perlin(noise_b)
	local noise_height = minetest.get_perlin(noise_h)
	local noise_mount = minetest.get_perlin(noise_m)
	local base_max = floatland_y
	local y = 1283
	for i = 1, 10000 do
	    local x = math.random(-2000, 2000)
	    local z = math.random(-2000, 2000)
	    local n_base = noise_base:get2d({x = x, y = z})
	    local n_mount = noise_mount:get3d({x = x, y = y, z = z})
	    local density_gradient = -math.pow((y - floatland_y) / mount_height, 0.75)
	    local floatn = n_mount + mount_dens + density_gradient >= 0
		if n_base > 0 and floatn == false then -- If floatlands and not a mountain
			local n_base_height = math.max(noise_height:get2d({x = x, y = z}), 1)
			local amp = n_base * n_base_height
			local ridge = n_base_height / 3
			--if amp > ridge * 2 then -- Lakebed
			--	base_max = 1280 - (amp - ridge * 2) / 2
			--else -- Normal terrain
			if amp < ridge * 2 then
				local diff = math.abs(amp - ridge) / ridge
				local smooth_diff = diff * diff * (3 - 2 * diff)
				base_max = 1280 + ridge - smooth_diff * ridge
			end
			return {x = x, y = base_max + 2, z = z}
		end
	end
end

minetest.register_on_newplayer(function(player)
	player:set_pos(spawn_point())
end)

minetest.register_on_respawnplayer(function(player)
	player:set_pos(spawn_point())
	return true
end)
