-- Turret, sponson and pintle mounts (user, 2026-11-17; the column is V3_26). The reader now keeps how each
-- weapon is mounted: everything in a vehicle's turret, a VTOL's chin turret too, is TURRET; a vehicle weapon
-- marked (ST) is SPONSON and (PT) PINTLE; a mech weapon whose slots say (T) is TURRET. A mech's turret itself
-- is now equipment, as a vehicle's sponson turret and pintle mount already were (user, 2026-11-17).
--
-- Generated from all units re-imported with the new reader (mm-data at
-- d195e171b3c87801c8dbc5ffcb5f763e5da57483) compared with the database before. Nothing else changes.
--   1. the items in vehicle turret locations: TURRET (2,673 rows)
--   2. 128 sponson weapons on 35 vehicles, 9 pintle weapons on 5 support vehicles and 68 turret weapons
--      on 27 mechs, by unit, location and item
--   3. the Head, Shoulder and Quad Turret: equipment named as V3_21 would (MegaMek's "BattleMech Turret
--      (Quad)" is the Quad Turret), with the slang load's terms, and 30 items on 27 mechs
-- They stay in no equipment group, like the sponson turret and pintle mount (V3_23).
--
-- Each step only changes what isn't done yet, so a database that already re-imported the units keeps its rows.
-- The unit data comes from MegaMek (https://megamek.org), licensed CC BY-NC-SA 4.0.
-- Data migrations after V3_8 update what's stored; see the importers skill.

-- 1.
UPDATE unit_equipment SET turret_mount = 'TURRET'
WHERE location IN ('FRONTTURRET', 'REARTURRET') AND turret_mount IS NULL;

-- 2. a unit has no weapon both on a mount and off it in one location, so each of its rows there gets it (the
-- comment says how many rows that is, when more than one)
UPDATE unit_equipment ue SET turret_mount = v.turret_mount
FROM (VALUES
    ('019f583e-d6da-7c63-8448-81a8356819e4'::uuid, 'RIGHT_TORSO', 'ermediumlaser', 'CLAN', 'TURRET'), -- Araña ARA-S-1 MilitiaMech, 3
    ('019f583e-dc50-708e-b558-cb3d6b1c62dc'::uuid, 'RIGHT_TORSO', 'srm6', 'CLAN', 'TURRET'), -- Baboon 6, 2
    ('019f583e-e7a8-7143-8855-aa89c2439f30'::uuid, 'LEFT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Ballista Artillery Trailer, 2
    ('019f583e-e7a8-7143-8855-aa89c2439f30'::uuid, 'RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Ballista Artillery Trailer, 2
    ('019f583e-e7f6-7625-b1fb-bd307d3112ad'::uuid, 'LEFT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Bardiche Heavy Strike Tank, 2
    ('019f583e-e7f6-7625-b1fb-bd307d3112ad'::uuid, 'RIGHT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Bardiche Heavy Strike Tank, 2
    ('019f583e-e8a7-7662-b59b-1976a42bf411'::uuid, 'LEFT', 'apgaussrifle', 'CLAN', 'SPONSON'), -- Bardiche Heavy Strike Tank C, 2
    ('019f583e-e8a7-7662-b59b-1976a42bf411'::uuid, 'RIGHT', 'apgaussrifle', 'CLAN', 'SPONSON'), -- Bardiche Heavy Strike Tank C, 2
    ('019f583e-e7f5-7aa1-a5bb-a4e99a299af1'::uuid, 'LEFT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Bardiche Heavy Strike Tank (Minesweeper), 2
    ('019f583e-e7f5-7aa1-a5bb-a4e99a299af1'::uuid, 'RIGHT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Bardiche Heavy Strike Tank (Minesweeper), 2
    ('019f583e-d75e-77f1-87b7-a40b2d2dce5b'::uuid, 'LEFT_TORSO', 'erlargelaser', 'INNER_SPHERE', 'TURRET'), -- Barghest BGS-4T
    ('019f583e-d75e-77f1-87b7-a40b2d2dce5b'::uuid, 'LEFT_TORSO', 'ermediumlaser', 'INNER_SPHERE', 'TURRET'), -- Barghest BGS-4T
    ('019f583e-e090-77a9-af68-2af67690ea78'::uuid, 'LEFT_TORSO', 'lightppc', 'INNER_SPHERE', 'TURRET'), -- Barghest BGS-4X, 2
    ('019f583e-e9fc-79fc-ae2c-a0e5d9b4795d'::uuid, 'LEFT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Behemoth Heavy Tank (Davion)
    ('019f583e-e9fc-79fc-ae2c-a0e5d9b4795d'::uuid, 'LEFT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Behemoth Heavy Tank (Davion)
    ('019f583e-e9fc-79fc-ae2c-a0e5d9b4795d'::uuid, 'RIGHT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Behemoth Heavy Tank (Davion)
    ('019f583e-e9fc-79fc-ae2c-a0e5d9b4795d'::uuid, 'RIGHT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Behemoth Heavy Tank (Davion)
    ('019f583e-ea00-70b7-b423-47656fd503e3'::uuid, 'LEFT', 'mml5', 'INNER_SPHERE', 'SPONSON'), -- Behemoth Heavy Tank (Liao)
    ('019f583e-ea00-70b7-b423-47656fd503e3'::uuid, 'RIGHT', 'mml5', 'INNER_SPHERE', 'SPONSON'), -- Behemoth Heavy Tank (Liao)
    ('019f583e-e952-793a-8b90-5dd09c811f56'::uuid, 'LEFT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Challenger MBT Mk. XV, 2
    ('019f583e-e952-793a-8b90-5dd09c811f56'::uuid, 'RIGHT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Challenger MBT Mk. XV, 2
    ('019f583e-ebd9-7caa-8582-547e107eabd8'::uuid, 'LEFT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Challenger MBT XVc, 2
    ('019f583e-ebd9-7caa-8582-547e107eabd8'::uuid, 'RIGHT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Challenger MBT XVc, 2
    ('019f583e-ec7e-7b9b-b6bb-40be930a143f'::uuid, 'LEFT', 'flamer(vehicle)', 'INNER_SPHERE', 'SPONSON'), -- Condor Heavy Hover Tank (Fission)
    ('019f583e-ec7e-7b9b-b6bb-40be930a143f'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Condor Heavy Hover Tank (Fission)
    ('019f583e-ec7e-7b9b-b6bb-40be930a143f'::uuid, 'RIGHT', 'flamer(vehicle)', 'INNER_SPHERE', 'SPONSON'), -- Condor Heavy Hover Tank (Fission)
    ('019f583e-ec7e-7b9b-b6bb-40be930a143f'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Condor Heavy Hover Tank (Fission)
    ('019f583e-e85c-741f-b90c-aeb1465e88b0'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Crane Heavy Transport, 2
    ('019f583e-e85c-741f-b90c-aeb1465e88b0'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Crane Heavy Transport, 2
    ('019f583e-d761-79fb-8908-61dbe2b56205'::uuid, 'LEFT_TORSO', 'rifle(cannon,heavy)', 'INNER_SPHERE', 'TURRET'), -- Deep Lord RCL-Z1M MilitiaMech
    ('019f583e-ebca-7858-a00c-8c3629f465da'::uuid, 'LEFT', 'mediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Demon Tank CX-2
    ('019f583e-ebca-7858-a00c-8c3629f465da'::uuid, 'RIGHT', 'mediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Demon Tank CX-2
    ('019f583e-e7a9-7a3a-bc7b-1d5353eb104a'::uuid, 'FRONT_LEFT', 'anti-missilesystem', 'INNER_SPHERE', 'SPONSON'), -- Destrier Siege Vehicle
    ('019f583e-e7a9-7a3a-bc7b-1d5353eb104a'::uuid, 'FRONT_LEFT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Destrier Siege Vehicle, 2
    ('019f583e-e7a9-7a3a-bc7b-1d5353eb104a'::uuid, 'FRONT_RIGHT', 'anti-missilesystem', 'INNER_SPHERE', 'SPONSON'), -- Destrier Siege Vehicle
    ('019f583e-e7a9-7a3a-bc7b-1d5353eb104a'::uuid, 'FRONT_RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Destrier Siege Vehicle, 2
    ('019f583e-e8a9-7832-8227-e6b2f1d99586'::uuid, 'FRONT_LEFT', 'ermediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Devastator II Superheavy Tank
    ('019f583e-e8a9-7832-8227-e6b2f1d99586'::uuid, 'FRONT_RIGHT', 'ermediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Devastator II Superheavy Tank
    ('019f583e-dfbc-74c8-afd9-06dd48506e5b'::uuid, 'LEFT_TORSO', 'rifle(cannon,heavy)', 'INNER_SPHERE', 'TURRET'), -- Dig Lord RCL-Z1 Armed MiningMech
    ('019f583e-da77-7bc8-ae08-b22eaeb67d42'::uuid, 'RIGHT_TORSO', 'atm12', 'CLAN', 'TURRET'), -- Doom Courser A, 2
    ('019f583e-da79-7588-8d23-fefc23e760ad'::uuid, 'RIGHT_TORSO', 'mediumpulselaser', 'CLAN', 'TURRET'), -- Doom Courser B, 4
    ('019f583e-da7a-7b18-8a7c-c5f1a1b62209'::uuid, 'RIGHT_TORSO', 'lrm15', 'CLAN', 'TURRET'), -- Doom Courser C, 4
    ('019f583e-da7c-718c-940b-19a11197ad03'::uuid, 'RIGHT_TORSO', 'erppc', 'CLAN', 'TURRET'), -- Doom Courser D
    ('019f583e-da7e-7ac8-b351-b8109c07f5ce'::uuid, 'RIGHT_TORSO', 'erppc', 'CLAN', 'TURRET'), -- Doom Courser Prime
    ('019f583e-da7e-7ac8-b351-b8109c07f5ce'::uuid, 'RIGHT_TORSO', 'lrm20', 'CLAN', 'TURRET'), -- Doom Courser Prime
    ('019f583e-ec0a-7340-a6c3-f2700c3efca1'::uuid, 'FRONT_LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Dreadnought Mk II Land Train, 3
    ('019f583e-ec0a-7340-a6c3-f2700c3efca1'::uuid, 'FRONT_LEFT', 'machinegunarray', 'INNER_SPHERE', 'SPONSON'), -- Dreadnought Mk II Land Train
    ('019f583e-ec0a-7340-a6c3-f2700c3efca1'::uuid, 'FRONT_RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Dreadnought Mk II Land Train, 3
    ('019f583e-ec0a-7340-a6c3-f2700c3efca1'::uuid, 'FRONT_RIGHT', 'machinegunarray', 'INNER_SPHERE', 'SPONSON'), -- Dreadnought Mk II Land Train
    ('019f583e-ebfa-7f3a-b14f-4d595f39441f'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Fensalir Combat WiGE (XXL), 2
    ('019f583e-ebfa-7f3a-b14f-4d595f39441f'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Fensalir Combat WiGE (XXL), 2
    ('019f583e-e9a2-7f5f-a0e6-21505a7828c2'::uuid, 'LEFT', 'mediumchemicallaser', 'CLAN', 'SPONSON'), -- Galleon Light Tank C
    ('019f583e-e9a2-7f5f-a0e6-21505a7828c2'::uuid, 'RIGHT', 'mediumchemicallaser', 'CLAN', 'SPONSON'), -- Galleon Light Tank C
    ('019f583e-e8af-7d8d-bb9d-ecd43e34449c'::uuid, 'LEFT', 'ermediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-105
    ('019f583e-e8af-7d8d-bb9d-ecd43e34449c'::uuid, 'RIGHT', 'ermediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-105
    ('019f583e-e9a3-7e6f-b24f-6f260369d533'::uuid, 'LEFT', 'mediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-106
    ('019f583e-e9a3-7e6f-b24f-6f260369d533'::uuid, 'RIGHT', 'mediumlaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-106
    ('019f583e-e9a6-7443-bcee-2509449c6aa8'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-106M
    ('019f583e-e9a6-7443-bcee-2509449c6aa8'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-106M
    ('019f583e-e9a9-7445-9d27-ceb1b4c592b5'::uuid, 'LEFT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-201
    ('019f583e-e9a9-7445-9d27-ceb1b4c592b5'::uuid, 'RIGHT', 'magshot', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-201
    ('019f583e-e9aa-72e3-8eaf-0c6020ee960f'::uuid, 'LEFT', 'ersmalllaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-300
    ('019f583e-e9aa-72e3-8eaf-0c6020ee960f'::uuid, 'RIGHT', 'ersmalllaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank GAL-300
    ('019f583e-ebf0-7a41-8fbf-a3cf2d538ddd'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank Maxwell
    ('019f583e-ebf0-7a41-8fbf-a3cf2d538ddd'::uuid, 'LEFT', 'smallpulselaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank Maxwell
    ('019f583e-ebf0-7a41-8fbf-a3cf2d538ddd'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank Maxwell
    ('019f583e-ebf0-7a41-8fbf-a3cf2d538ddd'::uuid, 'RIGHT', 'smallpulselaser', 'INNER_SPHERE', 'SPONSON'), -- Galleon Light Tank Maxwell
    ('019f583e-d7d7-77a3-9412-0f7421a71e73'::uuid, 'LEFT_TORSO', 'erlargelaser', 'CLAN', 'TURRET'), -- Goliath C
    ('019f583e-d7d7-77a3-9412-0f7421a71e73'::uuid, 'LEFT_TORSO', 'gaussrifle', 'CLAN', 'TURRET'), -- Goliath C
    ('019f583e-d7d7-77a3-9412-0f7421a71e73'::uuid, 'LEFT_TORSO', 'micropulselaser', 'CLAN', 'TURRET'), -- Goliath C
    ('019f583e-d167-7bfd-b6e6-2b35355911dc'::uuid, 'LEFT_TORSO', 'gaussrifle', 'INNER_SPHERE', 'TURRET'), -- Goliath GOL-6M
    ('019f583e-d167-7bfd-b6e6-2b35355911dc'::uuid, 'LEFT_TORSO', 'mml7', 'INNER_SPHERE', 'TURRET'), -- Goliath GOL-6M
    ('019f583e-da9b-72ed-bf42-ffbd29eb9567'::uuid, 'LEFT_TORSO', 'lrm20', 'INNER_SPHERE', 'TURRET'), -- Grand Crusader GRN-D-01-X
    ('019f583e-da9b-72ed-bf42-ffbd29eb9567'::uuid, 'RIGHT_TORSO', 'lrm20', 'INNER_SPHERE', 'TURRET'), -- Grand Crusader GRN-D-01-X
    ('019f583e-e7ab-779f-b06f-a796df22ab88'::uuid, 'LEFT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Hanse MBT, 2
    ('019f583e-e7ab-779f-b06f-a796df22ab88'::uuid, 'RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Hanse MBT, 2
    ('019f583e-ec62-7350-a95d-29fd46706bbc'::uuid, 'FRONT_LEFT', 'anti-missilesystem', 'INNER_SPHERE', 'SPONSON'), -- Hexareme HQ Hovercraft
    ('019f583e-ec62-7350-a95d-29fd46706bbc'::uuid, 'FRONT_LEFT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Hexareme HQ Hovercraft
    ('019f583e-ec62-7350-a95d-29fd46706bbc'::uuid, 'FRONT_RIGHT', 'anti-missilesystem', 'INNER_SPHERE', 'SPONSON'), -- Hexareme HQ Hovercraft
    ('019f583e-ec62-7350-a95d-29fd46706bbc'::uuid, 'FRONT_RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Hexareme HQ Hovercraft
    ('019f583e-e83a-74e0-812a-87e7aa03d7e2'::uuid, 'LEFT', 'apgaussrifle', 'CLAN', 'SPONSON'), -- Huitzilopochtli Assault Tank 'Huey' (LRM)
    ('019f583e-e83a-74e0-812a-87e7aa03d7e2'::uuid, 'RIGHT', 'apgaussrifle', 'CLAN', 'SPONSON'), -- Huitzilopochtli Assault Tank 'Huey' (LRM)
    ('019f583e-e83c-764e-bcdf-de334c7016c0'::uuid, 'LEFT', 'apgaussrifle', 'CLAN', 'SPONSON'), -- Huitzilopochtli Assault Tank 'Huey' (Streak)
    ('019f583e-e83c-764e-bcdf-de334c7016c0'::uuid, 'RIGHT', 'apgaussrifle', 'CLAN', 'SPONSON'), -- Huitzilopochtli Assault Tank 'Huey' (Streak)
    ('019f583e-e913-7389-a648-0624c05f2f44'::uuid, 'LEFT', 'gaussrifle,light(kingdavid)', 'INNER_SPHERE', 'PINTLE'), -- Ibex RV (Militarized:Gauss)
    ('019f583e-e913-7389-a648-0624c05f2f44'::uuid, 'RIGHT', 'gaussrifle,light(kingdavid)', 'INNER_SPHERE', 'PINTLE'), -- Ibex RV (Militarized:Gauss)
    ('019f583e-e914-7693-8724-943128800a78'::uuid, 'LEFT', 'lightmachinegun', 'INNER_SPHERE', 'PINTLE'), -- Ibex RV (Militarized:MG)
    ('019f583e-e914-7693-8724-943128800a78'::uuid, 'RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'PINTLE'), -- Ibex RV (Militarized:MG)
    ('019f583e-ebbf-7a60-a6b5-a991440f2cef'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Jagdpanzer II
    ('019f583e-ebbf-7a60-a6b5-a991440f2cef'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Jagdpanzer II
    ('019f583e-d57d-7da4-8a2e-9782be66acf5'::uuid, 'RIGHT_TORSO', 'atm6', 'CLAN', 'TURRET'), -- Jaguar Jaguar prime
    ('019f583e-ebff-7bd6-ae28-038f8e1c20d4'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Karnov UR Transport (Heavy Stealth)
    ('019f583e-ebff-7bd6-ae28-038f8e1c20d4'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Karnov UR Transport (Heavy Stealth)
    ('019f583e-ebcd-7e0d-9ed5-753acb186788'::uuid, 'LEFT', 'rocketlauncher15', 'INNER_SPHERE', 'SPONSON'), -- Lightning Attack Hovercraft CX-3, 3
    ('019f583e-ebcd-7e0d-9ed5-753acb186788'::uuid, 'RIGHT', 'rocketlauncher15', 'INNER_SPHERE', 'SPONSON'), -- Lightning Attack Hovercraft CX-3, 3
    ('019f583e-eb0e-7b5f-afa0-b120634189cc'::uuid, 'LEFT', 'auto-rifle(modern,generic)', 'INNER_SPHERE', 'PINTLE'), -- Limpet Half-Track
    ('019f583e-eb0e-7b5f-afa0-b120634189cc'::uuid, 'RIGHT', 'auto-rifle(modern,generic)', 'INNER_SPHERE', 'PINTLE'), -- Limpet Half-Track
    ('019f583e-ebd0-7d5d-b967-89609fb4de53'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Maxim Flanker, 3
    ('019f583e-ebd0-7d5d-b967-89609fb4de53'::uuid, 'LEFT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Maxim Flanker
    ('019f583e-ebd0-7d5d-b967-89609fb4de53'::uuid, 'RIGHT', 'lrm15', 'INNER_SPHERE', 'SPONSON'), -- Maxim Flanker
    ('019f583e-ebd0-7d5d-b967-89609fb4de53'::uuid, 'RIGHT', 'srm4', 'INNER_SPHERE', 'SPONSON'), -- Maxim Flanker
    ('019f583e-e964-7045-a17d-3a5de2971908'::uuid, 'LEFT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Myrmidon Medium Tank (Anti-Infantry), 3
    ('019f583e-e964-7045-a17d-3a5de2971908'::uuid, 'RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Myrmidon Medium Tank (Anti-Infantry), 3
    ('019f583e-ec19-771c-9dd9-7727db87b468'::uuid, 'LEFT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Myrmidon Medium Tank P (Tate), 3
    ('019f583e-ec19-771c-9dd9-7727db87b468'::uuid, 'LEFT', 'lightmachinegunarray', 'INNER_SPHERE', 'SPONSON'), -- Myrmidon Medium Tank P (Tate)
    ('019f583e-ec19-771c-9dd9-7727db87b468'::uuid, 'RIGHT', 'lightmachinegun', 'INNER_SPHERE', 'SPONSON'), -- Myrmidon Medium Tank P (Tate), 3
    ('019f583e-ec19-771c-9dd9-7727db87b468'::uuid, 'RIGHT', 'lightmachinegunarray', 'INNER_SPHERE', 'SPONSON'), -- Myrmidon Medium Tank P (Tate)
    ('019f583e-ea64-7933-93eb-c6be11ec1aee'::uuid, 'RIGHT', 'machinegun(support)', 'INNER_SPHERE', 'PINTLE'), -- Outrider
    ('019f583e-ec63-749c-874b-38521fd472da'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Quaestor Mobile Tactical Command HQ
    ('019f583e-ec63-749c-874b-38521fd472da'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Quaestor Mobile Tactical Command HQ
    ('019f583e-df72-7ffc-9bd9-28cc2ee3f881'::uuid, 'HEAD', 'ppc', 'INNER_SPHERE', 'TURRET'), -- Quickdraw QKD-8X
    ('019f583e-eb1c-7f90-b0d5-d9443332c6d7'::uuid, 'LEFT', 'auto-rifle(modern,generic)', 'INNER_SPHERE', 'PINTLE'), -- Rock Rover Half-Track RRV
    ('019f583e-eb1c-7f90-b0d5-d9443332c6d7'::uuid, 'RIGHT', 'auto-rifle(modern,generic)', 'INNER_SPHERE', 'PINTLE'), -- Rock Rover Half-Track RRV
    ('019f583e-d39e-7970-a863-4663890aecf8'::uuid, 'RIGHT_TORSO', 'ermediumlaser', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1O
    ('019f583e-d39e-7970-a863-4663890aecf8'::uuid, 'RIGHT_TORSO', 'heavyppc', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1O
    ('019f583e-d39e-7970-a863-4663890aecf8'::uuid, 'RIGHT_TORSO', 'lightppc', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1O
    ('019f583e-d3a0-7a86-99d6-5443c5e618a8'::uuid, 'RIGHT_TORSO', 'lrm15', 'CLAN', 'TURRET'), -- Sarath SRTH-1OA, 2
    ('019f583e-d3a0-7a86-99d6-5443c5e618a8'::uuid, 'RIGHT_TORSO', 'mml3', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1OA, 2
    ('019f583e-d3a1-733e-9524-dffedd125b3a'::uuid, 'RIGHT_TORSO', 'erflamer', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1OB, 4
    ('019f583e-d3a1-733e-9524-dffedd125b3a'::uuid, 'RIGHT_TORSO', 'mediumlaser', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1OB, 2
    ('019f583e-d3a1-733e-9524-dffedd125b3a'::uuid, 'RIGHT_TORSO', 'plasmarifle', 'INNER_SPHERE', 'TURRET'), -- Sarath SRTH-1OB
    ('019f583e-d3c8-78a7-ae64-d874fae56e71'::uuid, 'RIGHT_TORSO', 'heavylargelaser', 'CLAN', 'TURRET'), -- Stalking Spider II Stalking Spider II prime
    ('019f583e-d3c8-78a7-ae64-d874fae56e71'::uuid, 'RIGHT_TORSO', 'srm4', 'CLAN', 'TURRET'), -- Stalking Spider II Stalking Spider II prime, 2
    ('019f583e-d783-7686-909d-37df1a1c38c7'::uuid, 'LEFT_TORSO', 'ermediumlaser', 'INNER_SPHERE', 'TURRET'), -- Stiletto STO-6S, 2
    ('019f583e-d783-7686-909d-37df1a1c38c7'::uuid, 'RIGHT_TORSO', 'ermediumlaser', 'INNER_SPHERE', 'TURRET'), -- Stiletto STO-6S, 2
    ('019f583e-e095-743e-923d-0b2ffb2fbae4'::uuid, 'LEFT_TORSO', 'ermediumlaser', 'INNER_SPHERE', 'TURRET'), -- Stiletto STO-6X, 2
    ('019f583e-e095-743e-923d-0b2ffb2fbae4'::uuid, 'RIGHT_TORSO', 'ermediumlaser', 'INNER_SPHERE', 'TURRET'), -- Stiletto STO-6X, 2
    ('019f583e-e979-7074-b52f-d31b6065d77b'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Angel
    ('019f583e-e979-7074-b52f-d31b6065d77b'::uuid, 'LEFT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Angel
    ('019f583e-e979-7074-b52f-d31b6065d77b'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Angel
    ('019f583e-e979-7074-b52f-d31b6065d77b'::uuid, 'RIGHT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Angel
    ('019f583e-ebf2-7562-b125-b8b6450cc5d1'::uuid, 'LEFT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Maxwell
    ('019f583e-ebf2-7562-b125-b8b6450cc5d1'::uuid, 'LEFT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Maxwell
    ('019f583e-ebf2-7562-b125-b8b6450cc5d1'::uuid, 'RIGHT', 'machinegun', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Maxwell
    ('019f583e-ebf2-7562-b125-b8b6450cc5d1'::uuid, 'RIGHT', 'srm2', 'INNER_SPHERE', 'SPONSON'), -- Thumper Artillery Vehicle Maxwell
    ('019f583e-d4ad-77ee-b531-8c232491ab5a'::uuid, 'HEAD', 'erppc', 'CLAN', 'TURRET'), -- Thunder Fox TFT-F11
    ('019f583e-de97-79b5-bd7e-2d6812f12b58'::uuid, 'RIGHT_TORSO', 'ermediumlaser', 'CLAN', 'TURRET'), -- Tolva Tolva prime, 3
    ('019f583e-d4b6-7700-ba17-713999976674'::uuid, 'LEFT_TORSO', 'erppc', 'INNER_SPHERE', 'TURRET'), -- Trebaruna TR-XH
    ('019f583e-d56d-7b87-b234-73e865a5abc3'::uuid, 'LEFT_TORSO', 'bombastlaser', 'INNER_SPHERE', 'TURRET'), -- Uraeus UAE-7R
    ('019f583e-df59-75fe-9cb1-8c9867e625a4'::uuid, 'HEAD', 'mediumx-pulselaser', 'INNER_SPHERE', 'TURRET') -- Volkh VKH-68, 4
) AS v (megamek_uuid, location, name, tech, turret_mount),
    unit u, unit_mech_equipment ume, equipment e
WHERE u.megamek_uuid = v.megamek_uuid AND ume.unit_id = u.id AND ume.mech_equipment_id = ue.id
  AND e.id = ue.equipment_id AND e.name = v.name AND e.tech = v.tech AND ue.location = v.location
  AND ue.turret_mount IS DISTINCT FROM v.turret_mount;

-- 3. the turrets, with their names and terms first
INSERT INTO equipment (id, crit_slots, heat, long_range, medium_range, min_range, name, short_range, tech, tonnage,
    display_name)
SELECT gen_random_uuid(), 0, 0, 0, 0, 0, v.name, 0, 'INNER_SPHERE', 0, v.display_name
FROM (VALUES
    ('battlemechturret(head)', 'Head Turret'),
    ('battlemechturret(shoulder)', 'Shoulder Turret'),
    ('battlemechturret(quad)', 'Quad Turret')
) AS v (name, display_name)
WHERE NOT EXISTS (SELECT 1 FROM equipment e WHERE e.name = v.name AND e.tech = 'INNER_SPHERE');

-- named as V3_21 names bracketed items, when an import added them first
UPDATE equipment e SET display_name = v.display_name
FROM (VALUES
    ('battlemechturret(head)', 'Head Turret'),
    ('battlemechturret(shoulder)', 'Shoulder Turret'),
    ('battlemechturret(quad)', 'Quad Turret')
) AS v (name, display_name)
WHERE e.name = v.name AND e.display_name IS DISTINCT FROM v.display_name;

-- the slang load's terms for them (MegaMek's names), and the typed name as a hand-written term, as V3_24: a
-- MegaMek name with the same key ("QuadTurret") becomes it, keeping its links
INSERT INTO slang (id, term, lookup, kind)
SELECT gen_random_uuid(), v.term, v.lookup, 'ALIAS'
FROM (VALUES
    ('BattleMech Turret (Head)', 'battlemechturrethead'),
    ('BattleMech Turret (Shoulder)', 'battlemechturretshoulder'),
    ('BattleMech Turret (Quad)', 'battlemechturretquad'),
    ('ISHeadTurret', 'isheadturret'),
    ('ISShoulderTurret', 'isshoulderturret'),
    ('ISQuadTurret', 'isquadturret')
) AS v (term, lookup)
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = v.lookup);

WITH typed (term, lookup) AS (VALUES
    ('head turret', 'headturret'),
    ('shoulder turret', 'shoulderturret'),
    ('quad turret', 'quadturret')
), taken AS (
    UPDATE slang s SET kind = 'SHORTHAND', term = typed.term
    FROM typed
    WHERE s.lookup = typed.lookup AND s.kind = 'ALIAS'
)
INSERT INTO slang (id, term, lookup, kind)
SELECT gen_random_uuid(), typed.term, typed.lookup, 'SHORTHAND' FROM typed
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = typed.lookup);

INSERT INTO slang_equipment (slang_id, equipment_id)
SELECT s.id, e.id
FROM (VALUES
    ('battlemechturrethead', 'battlemechturret(head)'),
    ('isheadturret', 'battlemechturret(head)'),
    ('headturret', 'battlemechturret(head)'),
    ('battlemechturretshoulder', 'battlemechturret(shoulder)'),
    ('isshoulderturret', 'battlemechturret(shoulder)'),
    ('shoulderturret', 'battlemechturret(shoulder)'),
    ('battlemechturretquad', 'battlemechturret(quad)'),
    ('isquadturret', 'battlemechturret(quad)'),
    ('quadturret', 'battlemechturret(quad)')
) AS l (lookup, name)
JOIN slang s ON s.lookup = l.lookup
JOIN equipment e ON e.name = l.name
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- the mechs' turrets, each where its slots are; only while a mech has fewer there than this
CREATE TEMPORARY TABLE v3_27_turret AS
SELECT u.id AS unit_id, e.id AS equipment_id, v.location, v.count - (
    SELECT count(*) FROM unit_mech_equipment ume JOIN unit_equipment ue ON ue.id = ume.mech_equipment_id
    WHERE ume.unit_id = u.id AND ue.equipment_id = e.id AND ue.location = v.location) AS missing
FROM (VALUES
    ('019f583e-d6da-7c63-8448-81a8356819e4'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Araña ARA-S-1 MilitiaMech
    ('019f583e-dc50-708e-b558-cb3d6b1c62dc'::uuid, 'RIGHT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Baboon 6
    ('019f583e-d75e-77f1-87b7-a40b2d2dce5b'::uuid, 'LEFT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Barghest BGS-4T
    ('019f583e-e090-77a9-af68-2af67690ea78'::uuid, 'LEFT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Barghest BGS-4X
    ('019f583e-d761-79fb-8908-61dbe2b56205'::uuid, 'LEFT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Deep Lord RCL-Z1M MilitiaMech
    ('019f583e-dfbc-74c8-afd9-06dd48506e5b'::uuid, 'LEFT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Dig Lord RCL-Z1 Armed MiningMech
    ('019f583e-da77-7bc8-ae08-b22eaeb67d42'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Doom Courser A
    ('019f583e-da79-7588-8d23-fefc23e760ad'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Doom Courser B
    ('019f583e-da7a-7b18-8a7c-c5f1a1b62209'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Doom Courser C
    ('019f583e-da7c-718c-940b-19a11197ad03'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Doom Courser D
    ('019f583e-da7e-7ac8-b351-b8109c07f5ce'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Doom Courser Prime
    ('019f583e-d7d7-77a3-9412-0f7421a71e73'::uuid, 'LEFT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Goliath C
    ('019f583e-d167-7bfd-b6e6-2b35355911dc'::uuid, 'LEFT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Goliath GOL-6M
    ('019f583e-da9b-72ed-bf42-ffbd29eb9567'::uuid, 'LEFT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Grand Crusader GRN-D-01-X
    ('019f583e-da9b-72ed-bf42-ffbd29eb9567'::uuid, 'RIGHT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Grand Crusader GRN-D-01-X
    ('019f583e-d57d-7da4-8a2e-9782be66acf5'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Jaguar Jaguar prime
    ('019f583e-df72-7ffc-9bd9-28cc2ee3f881'::uuid, 'CENTER_TORSO', 'battlemechturret(head)', 'INNER_SPHERE', 1), -- Quickdraw QKD-8X
    ('019f583e-d39e-7970-a863-4663890aecf8'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Sarath SRTH-1O
    ('019f583e-d3a0-7a86-99d6-5443c5e618a8'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Sarath SRTH-1OA
    ('019f583e-d3a1-733e-9524-dffedd125b3a'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Sarath SRTH-1OB
    ('019f583e-d3c8-78a7-ae64-d874fae56e71'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Stalking Spider II Stalking Spider II prime
    ('019f583e-d783-7686-909d-37df1a1c38c7'::uuid, 'LEFT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Stiletto STO-6S
    ('019f583e-d783-7686-909d-37df1a1c38c7'::uuid, 'RIGHT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Stiletto STO-6S
    ('019f583e-e095-743e-923d-0b2ffb2fbae4'::uuid, 'LEFT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Stiletto STO-6X
    ('019f583e-e095-743e-923d-0b2ffb2fbae4'::uuid, 'RIGHT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Stiletto STO-6X
    ('019f583e-d4ad-77ee-b531-8c232491ab5a'::uuid, 'CENTER_TORSO', 'battlemechturret(head)', 'INNER_SPHERE', 1), -- Thunder Fox TFT-F11
    ('019f583e-de97-79b5-bd7e-2d6812f12b58'::uuid, 'RIGHT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Tolva Tolva prime
    ('019f583e-d4b6-7700-ba17-713999976674'::uuid, 'LEFT_TORSO', 'battlemechturret(quad)', 'INNER_SPHERE', 1), -- Trebaruna TR-XH
    ('019f583e-d56d-7b87-b234-73e865a5abc3'::uuid, 'LEFT_TORSO', 'battlemechturret(shoulder)', 'INNER_SPHERE', 1), -- Uraeus UAE-7R
    ('019f583e-df59-75fe-9cb1-8c9867e625a4'::uuid, 'CENTER_TORSO', 'battlemechturret(head)', 'INNER_SPHERE', 1) -- Volkh VKH-68
) AS v (megamek_uuid, location, name, tech, count)
JOIN unit u ON u.megamek_uuid = v.megamek_uuid
JOIN equipment e ON e.name = v.name AND e.tech = v.tech;

CREATE TEMPORARY TABLE v3_27_item AS
SELECT gen_random_uuid() AS id, t.unit_id, t.equipment_id, t.location
FROM v3_27_turret t, generate_series(1, t.missing);

INSERT INTO unit_equipment (id, location, omni_pod, rear_facing, tonnage, equipment_id)
SELECT id, location, false, false, 0, equipment_id FROM v3_27_item;

INSERT INTO unit_mech_equipment (unit_id, mech_equipment_id)
SELECT unit_id, id FROM v3_27_item;

DROP TABLE v3_27_item;
DROP TABLE v3_27_turret;
