    modelPrecache()
    {
        level.propIDs = [];

    #ifdef MW2
        if(level.currentMapName == "mp_afghan")
        {
            level.propIDs = [
                "machinery_oxygen_tank01",
                "foliage_pacific_bushtree02_animated",
                "foliage_cod5_tree_jungle_02_animated",
                "machinery_oxygen_tank02",
                "com_barrel_russian_fuel_dirt",
                "com_locker_double",
                "foliage_pacific_bushtree02_halfsize_animated",
                "com_plasticcase_black_big_us_dirt",
                "foliage_pacific_bushtree01_halfsize_animated",
                "vehicle_uaz_open_destructible",
                "vehicle_hummer_destructible",
                "foliage_cod5_tree_pine05_large_animated",
                "utility_transformer_ratnest01",
                "utility_water_collector"
            ];
        }

        else if(level.currentMapName == "mp_derail")
        {
            level.propIDs = [
                "com_roofvent2_animated",
                "com_filecabinetblackclosed",
                "com_tv1_testpattern",
                "usa_gas_station_trash_bin_02",
                "prop_photocopier_destructible_02",
                "machinery_oxygen_tank01",
                "com_trashbin01",
                "vehicle_pickup_destructible_mp",
                "furniture_gaspump01_damaged",
                "vehicle_uaz_winter_destructible",
                "com_propane_tank02",
                "crashed_satellite",
                "vehicle_bm21_cover_destructible",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_boneyard")
        {
            level.propIDs = [
                "foliage_tree_oak_1_animated2",
                "machinery_oxygen_tank01",
                "com_filecabinetblackclosed",
                "machinery_oxygen_tank02",
                "com_electrical_transformer_large_dam",
                "vehicle_moving_truck_destructible",
                "foliage_pacific_bushtree02_animated",
                "vehicle_pickup_destructible_mp",
                "com_trashbin02",
                "vehicle_bm21_mobile_bed_destructible",
                "foliage_cod5_tree_jungle_02_animated",
                "com_firehydrant",
                "machinery_generator",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_underpass")
        {
            level.propIDs = [
                "foliage_pacific_bushtree01_halfsize_animated",
                "utility_water_collector",
                "com_propane_tank02",
                "foliage_pacific_bushtree01_animated",
                "vehicle_van_slate_destructible",
                "com_locker_double",
                "machinery_oxygen_tank01",
                "prop_photocopier_destructible_02",
                "usa_gas_station_trash_bin_02",
                "machinery_oxygen_tank02",
                "com_filecabinetblackclosed",
                "vehicle_pickup_destructible_mp",
                "foliage_cod5_tree_jungle_02_animated",
                "foliage_tree_oak_1_animated2",
                "foliage_pacific_palms08_animated",
                "chicken_black_white",
                "utility_transformer_ratnest01",
                "utility_transformer_small01",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_highrise")
        {
            level.propIDs = [
                "ma_flatscreen_tv_wallmount_01",
                "com_trashbin02",
                "com_filecabinetblackclosed",
                "prop_photocopier_destructible_02",
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "com_electrical_transformer_large_dam",
                "com_roofvent2_animated",
                "com_propane_tank02",
                "highrise_fencetarp_04",
                "highrise_fencetarp_05",
                "com_barrel_benzin",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_estate")
        {
            level.propIDs = [
                "machinery_generator",
                "vehicle_pickup_destructible_mp",
                "vehicle_coupe_white_destructible",
                "vehicle_suburban_destructible_dull",
                "vehicle_luxurysedan_2008_destructible",
                "com_electrical_transformer_large_dam",
                "machinery_oxygen_tank01",
                "com_filecabinetblackclosed",
                "ma_flatscreen_tv_on_wallmount_02",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_terminal")
        {
            level.propIDs = [
                "com_tv1",
                "com_barrel_benzin",
                "foliage_pacific_fern01_animated",
                "ma_flatscreen_tv_wallmount_02",
                "com_roofvent2_animated",
                "ma_flatscreen_tv_on_wallmount_02_static",
                "vehicle_policecar_lapd_destructible",
                "com_vending_can_new2_lit",
                "usa_gas_station_trash_bin_01",
                "foliage_cod5_tree_pine05_large_animated",
                "com_filecabinetblackclosed",
                "com_plasticcase_black_big_us_dirt",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_subbase")
        {
            level.propIDs = [
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "com_trashcan_metal_closed",
                "com_tv1",
                "com_filecabinetblackclosed",
                "com_locker_double",
                "vehicle_uaz_winter_destructible",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_checkpoint")
        {
            level.propIDs = [
                "prop_photocopier_destructible_02",
                "com_filecabinetblackclosed",
                "com_firehydrant",
                "com_newspaperbox_red",
                "com_newspaperbox_blue",
                "com_tv1",
                "vehicle_moving_truck_destructible",
                "chicken_black_white",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_invasion")
        {
            level.propIDs = [
                "com_trashbin01",
                "com_trashbin02",
                "com_firehydrant",
                "com_newspaperbox_blue",
                "com_newspaperbox_red",
                "furniture_gaspump01_damaged",
                "vehicle_80s_wagon1_red_destructible_mp",
                "vehicle_hummer_destructible",
                "vehicle_taxi_yellow_destructible",
                "vehicle_uaz_open_destructible",
                "utility_transformer_small01",
                "foliage_tree_palm_tall_1",
                "foliage_tree_palm_bushy_1"
            ];
        }

        else if(level.currentMapName == "mp_quarry")
        {
            level.propIDs = [
                "foliage_pacific_bushtree02_animated",
                "foliage_tree_oak_1_animated2",
                "foliage_cod5_tree_jungle_02_animated",
                "com_filecabinetblackclosed",
                "machinery_generator",
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "utility_transformer_small01",
                "com_locker_double",
                "com_barrel_russian_fuel_dirt",
                "com_tv1",
                "vehicle_van_green_destructible",
                "vehicle_van_white_destructible",
                "vehicle_pickup_destructible_mp",
                "vehicle_small_hatch_turq_destructible_mp",
                "vehicle_uaz_open_destructible",
                "vehicle_moving_truck_destructible",
                "usa_gas_station_trash_bin_02",
                "prop_photocopier_destructible_02",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_nightshift")
        {
            level.propIDs = [
                "com_trashbin01",
                "com_trashbin02",
                "com_firehydrant",
                "com_newspaperbox_red",
                "com_newspaperbox_blue",
                "vehicle_uaz_open_destructible",
                "vehicle_van_white_destructible",
                "vehicle_bm21_cover_destructible",
                "com_filecabinetblackclosed",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_favela")
        {
            level.propIDs = [
                "utility_transformer_small01",
                "vehicle_small_hatch_white_destructible_mp",
                "vehicle_small_hatch_blue_destructible_mp",
                "vehicle_pickup_destructible_mp",
                "utility_water_collector",
                "com_tv2",
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "utility_transformer_ratnest01",
                "foliage_tree_palm_bushy_3",
                "com_firehydrant",
                "com_newspaperbox_red",
                "com_newspaperbox_blue",
                "com_trashbin01",
                "com_trashbin02"
            ];
        }

        else if(level.currentMapName == "mp_rundown")
        {
            level.propIDs = [
                "com_tv1",
                "com_tv2",
                "com_trashbin01",
                "com_trashbin02",
                "com_trashcan_metal_closed",
                "vehicle_small_hatch_white_destructible_mp",
                "vehicle_small_hatch_blue_destructible_mp",
                "vehicle_uaz_open_destructible",
                "vehicle_bm21_mobile_bed_destructible",
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "com_firehydrant",
                "foliage_tree_palm_bushy_1",
                "foliage_pacific_fern01_animated",
                "utility_transformer_small01",
                "utility_water_collector",
                "utility_transformer_ratnest01",
                "chicken_black_white"
            ];
        }

        else if(level.currentMapName == "mp_crash")
        {
            level.propIDs = [
                "com_tv1",
                "com_tv2",
                "ma_flatscreen_tv_wallmount_01",
                "ma_flatscreen_tv_wallmount_02",
                "foliage_tree_river_birch_xl_a_animated",
                "foliage_tree_palm_bushy_3",
                "foliage_tree_river_birch_med_a_animated",
                "utility_transformer_ratnest01",
                "utility_transformer_small01",
                "vehicle_80s_sedan1_brn_destructible_mp",
                "vehicle_80s_sedan1_green_destructible_mp",
                "vehicle_80s_sedan1_red_destructible_mp",
                "vehicle_pickup_destructible_mp"
            ];
        }

        else if(level.currentMapName == "mp_complex")
        {
            level.propIDs = [
                "usa_gas_station_trash_bin_02",
                "usa_gas_station_trash_bin_02_base",
                "ma_flatscreen_tv_on_02",
                "ma_flatscreen_tv_on_wallmount_02_static",
                "arcade_machine_1",
                "arcade_machine_2",
                "pinball_machine_1",
                "pinball_machine_2",
                "foliage_tree_green_pine_lg_b_animated",
                "foliage_tree_green_pine_lg_a_animated",
                "foliage_pacific_palms06_animated",
                "foliage_pacific_tropic_shrub01_animated",
                "vehicle_subcompact_black_destructible",
                "vehicle_subcompact_slate_destructible",
                "vehicle_pickup_destructible_mp",
                "vehicle_coupe_blue_destructible",
                "vehicle_coupe_white_destructible",
                "vehicle_policecar_lapd_destructible",
                "vehicle_moving_truck_destructible"
            ];
        }

        else if(level.currentMapName == "mp_overgrown")
        {
            level.propIDs = [
                "foliage_tree_river_birch_xl_a_animated",
                "foliage_tree_river_birch_lg_a_animated",
                "foliage_red_pine_xl_animated",
                "foliage_red_pine_xxl_animated",
                "foliage_red_pine_med_animated",
                "foliage_tree_grey_oak_xl_a_animated",
                "com_propane_tank02",
                "furniture_gaspump01_damaged"
            ];
        }

        else if(level.currentMapName == "mp_compact")
        {
            level.propIDs = [
                "com_locker_double",
                "machinery_generator",
                "com_filecabinetblackclosed",
                "com_propane_tank02",
                "machinery_oxygen_tank01",
                "me_rooftop_tank_01",
                "com_electrical_transformer_large_dam",
                "com_tv1",
                "com_filecabinetblackclosed_dam"
            ];
        }

        else if(level.currentMapName == "mp_trailerpark")
        {
            level.propIDs = [
                "prop_trailerpark_beer_keg",
                "foliage_dead_pine_med_animated",
                "foliage_dead_pine_lg_animated",
                "com_propane_tank02",
                "com_propane_tank03",
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "com_trashbin02",
                "machinery_generator",
                "com_firehydrant",
                "utility_transformer_ratnest01",
                "utility_transformer_small01",
                "vehicle_subcompact_gray_destructible",
                "vehicle_coupe_white_destructible",
                "vehicle_80s_hatch1_green_destructible_mp",
                "vehicle_80s_sedan1_red_destructible_mp",
                "vehicle_delivery_truck_white"
            ];
        }

        else if(level.currentMapName == "mp_abandon")
        {
            level.propIDs = [
                "popcorn_cart",
                "prop_trailerpark_beer_keg",
                "usa_gas_station_trash_bin_01",
                "trashcan_clown",
                "foliage_tree_river_birch_xl_a_animated",
                "arcade_machine_1",
                "arcade_machine_1_des",
                "arcade_machine_2",
                "pinball_machine_1",
                "pinball_machine_2",
                "pinball_machine_2_des",
                "fortune_machine",
                "vehicle_theme_park_truck"
            ];
        }

        else if(level.currentMapName == "mp_storm")
        {
            level.propIDs = [
                "com_tv1",
                "com_trashbin01",
                "com_filecabinetblackclosed",
                "com_filecabinetblackclosed_dam",
                "foliage_dead_pine_lg_animated",
                "foliage_dead_pine_med_animated",
                "foliage_tree_oak_1_animated2",
                "vehicle_80s_wagon1_green_destructible_mp",
                "vehicle_80s_sedan1_silv_destructible_mp",
                "vehicle_80s_hatch2_yel_destructible_mp",
                "vehicle_moving_truck_destructible",
                "vehicle_mack_truck_short_white_destructible"
            ];
        }

        else if(level.currentMapName == "mp_vacant")
        {
            level.propIDs = [
                "machinery_generator",
                "machinery_oxygen_tank02",
                "com_filecabinetblackclosed",
                "com_filecabinetblackclosed_dam",
                "foliage_tree_birch_red_1_animated",
                "foliage_tree_river_birch_xl_a_animated",
                "com_locker_double",
                "utility_transformer_small01",
                "vehicle_80s_sedan1_silv_destructible_mp",
                "vehicle_80s_sedan1_green_destructible_mp",
                "vehicle_80s_sedan1_red_destructible_mp",
                "vehicle_80s_sedan1_yel_destructible_mp",
                "vehicle_uaz_hardtop_destructible_mp",
                "com_propane_tank02"
            ];
        }

        else if(level.currentMapName == "mp_fuel2")
        {
            level.propIDs = [
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "com_filecabinetblackclosed",
                "com_filecabinetblackclosed_dam",
                "com_trashbin02",
                "machinery_generator",
                "foliage_tree_palm_med_2",
                "foliage_tree_palm_bushy_2",
                "utility_transformer_small01",
                "com_electrical_transformer_large_dam",
                "com_propane_tank02_small",
                "vehicle_uaz_hardtop_destructible_mp",
                "vehicle_bm21_mobile_bed_destructible"
            ];
        }

        else if(level.currentMapName == "mp_strike")
        {
            level.propIDs = [
                "machinery_oxygen_tank01",
                "machinery_oxygen_tank02",
                "com_filecabinetblackclosed",
                "com_filecabinetblackclosed_dam",
                "machinery_generator",
                "foliage_tree_river_birch_xl_a_animated",
                "foliage_tree_palm_bushy_2",
                "usa_gas_station_trash_bin_01",
                "com_locker_double",
                "com_trashcan_metal_closed",
                "com_firehydrant",
                "prop_photocopier_destructible_02",
                "com_vending_can_new1_lit",
                "com_vending_can_new2_lit",
                "vehicle_80s_sedan1_green_destructible_mp",
                "vehicle_80s_sedan1_brn_destructible_mp",
                "vehicle_hummer_destructible"
            ];
        }
    #endif
    
    #ifdef MW3
    //nothing to see here...yet ;)
    #endif

    for(a=0;a<level.propIDs.size;a++) 
        precachemodel(level.propIDs[a]);
    }