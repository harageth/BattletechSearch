-- Support vehicles (importers skill, bug 13; user, 2026-11-15): MegaMek's SupportTank, LargeSupportTank and
-- SupportVTOL files, stored as the SupportTank and SupportVtol unit types. Fixed-wing support aircraft wait for
-- an aircraft unit type.
--
-- Generated from a database V3_8 to V3_21 loaded and the vehicles then re-imported with the new reader
-- (mm-data at d195e171b3c87801c8dbc5ffcb5f763e5da57483), by comparing it with the database before:
--   0. every "Infantry Bay" stored so far is a vehicle's troop space, MegaMek's Infantry Compartment: the
--      equipment row is renamed, keeping its id and items. The reader now stores each <transporters> line as
--      its own bay in tons (TransportBay; Copilot on PR #26, user 2026-11-15); combat vehicles' bays are
--      fixed in V3_25.
--   1. 64 equipment no unit had before (chassis mods, infantry weapons, fire control, the bays, ...).
--      MegaMek's "Machine Gun (Light)" and "Flamer (Heavy)" are stored as the Light Machine Gun and Heavy
--      Flamer (user, 2026-11-15), so they add none.
--   2. 226 units (202 SupportTank, 24 SupportVtol; one more file has no MUL id, importers skill bug 25)
--   3. their 1,628 items
--   4. 139 MegaMek alias terms for the new equipment, and their 143 links
--   5. the Condor Heavy Hover Tank (Fission)'s two sponson flamers: "Flamer (Vehicle)(ST)" was cut at its
--      first bracket and stored as a Flamer; the reader now only takes the mounting note off the end
-- Nothing else changed. Rows are loaded into temporary tables and only what isn't stored yet is added, so a
-- database that already imported support vehicles keeps its own rows. Group memberships are V3_23.
--
-- The unit data comes from MegaMek (https://megamek.org), licensed CC BY-NC-SA 4.0.
-- Data migrations after V3_8 update what's stored; see the importers skill.

-- 0. (not where the new reader already stored an Infantry Compartment of that tech)
UPDATE equipment b SET name = 'infantrycompartment', display_name = 'Infantry Compartment'
WHERE b.name = 'infantrybay'
  AND NOT EXISTS (SELECT 1 FROM equipment c WHERE c.name = 'infantrycompartment' AND c.tech IS NOT DISTINCT FROM b.tech);

CREATE TEMPORARY TABLE v3_22_equipment (LIKE equipment);
CREATE TEMPORARY TABLE v3_22_unit (LIKE unit);
CREATE TEMPORARY TABLE v3_22_item (megamek_uuid uuid, id uuid, location varchar(255), omni_pod boolean,
    rear_facing boolean, tonnage double precision, turret_equipped boolean, name varchar(255), tech varchar(255),
    fire_control varchar(255), jump_boost integer, drones integer, mash_theaters integer);
CREATE TEMPORARY TABLE v3_22_slang (id uuid, term varchar(255), lookup varchar(255), kind varchar(255));
CREATE TEMPORARY TABLE v3_22_link (lookup varchar(255), name varchar(255), tech varchar(255));

-- 1.
COPY v3_22_equipment (id, crit_slots, damage, heat, long_range, medium_range, min_range, name, short_range, tech, tonnage, display_name) FROM stdin;
910775de-a657-4d57-a3d8-601606e8e28d	0	\N	0	0	0	0	advancedfirecontrol	0	CLAN	0	Advanced Fire Control
738149e9-5cef-4a90-94f8-ca1ba7a1a1ee	0	\N	0	0	0	0	autocannon(bearhuntersuperheavy)	0	CLAN	0	Autocannon (Bearhunter Superheavy)
d776c700-95dd-4614-b066-0abe05673a37	0	\N	0	0	0	0	autocannon(semi-portable)	0	INNER_SPHERE	0	Autocannon (Semi-Portable)
2953d15a-f2f9-4c6a-ad9b-f555be76496e	0	\N	0	0	0	0	auto-rifle(modern,generic)	0	INNER_SPHERE	0	Auto-Rifle (Modern, Generic)
dc1fb80d-35fa-4cee-a099-9b733e559d09	0	\N	0	0	0	0	basicfirecontrol	0	INNER_SPHERE	0	Basic Fire Control
9b55b25c-41bb-4b92-8ac3-8b8fe2abc72a	0	\N	0	0	0	0	bridgelayer(heavy)	0	INNER_SPHERE	0	Bridge Layer (Heavy)
b3dccef9-b62f-414e-b56e-a7e4b2cf6a58	0	\N	0	0	0	0	cargobay	0	CLAN	0	Cargo Bay
bccffdb1-810e-4b9a-83e3-1823ef3e882a	0	\N	0	0	0	0	cargobay	0	INNER_SPHERE	0	Cargo Bay
23638a1e-0365-4a0d-8dc8-11a1e3a3de58	0	\N	0	0	0	0	cargocontainer(10tons)	0	INNER_SPHERE	0	Cargo Container (10 tons)
2cad7e53-4ebe-4415-9dbc-fdb2f0e91218	0	\N	0	0	0	0	crewquarters	0	INNER_SPHERE	0	Crew Quarters
0d114072-7346-442d-953d-b75934244ca1	0	\N	0	0	0	0	ejectionseating	0	INNER_SPHERE	0	Ejection Seating
01a3a564-61d7-4dc3-84ec-396ccc569368	0	\N	0	0	0	0	environmentalsealing	0	INNER_SPHERE	0	Environmental Sealing
01a1a1ad-e53f-4ddf-ad31-722e379973e4	0	\N	0	0	0	0	fieldkitchen	0	INNER_SPHERE	0	Field Kitchen
5a4a348b-73d3-4d74-ac6b-f78ec622bb3b	0	\N	0	0	0	0	firstclassquarters	0	INNER_SPHERE	0	First Class Quarters
d072073d-d200-4f99-b895-7d7f9a7263e7	0	\N	0	0	0	0	fluidsuctionsystem(standard)	0	INNER_SPHERE	0	Fluid Suction System (Standard)
24e1cefc-90a8-4b18-acc2-dbdefc7524aa	0	\N	0	0	0	0	gaussrifle,light(kingdavid)	0	INNER_SPHERE	0	Gauss Rifle, Light (King David)
66793e6e-8820-4be3-a23f-f8e0e0b63ee4	0	\N	0	0	0	0	grenadelauncher(auto)	0	INNER_SPHERE	0	Grenade Launcher (Auto)
16acf3ec-c456-49dd-96a4-25d21f7f1dad	0	\N	0	0	0	0	grenadelauncher(heavy)	0	INNER_SPHERE	0	Grenade Launcher (Heavy)
fea2576e-26f2-4892-bc58-3de8695b8ea7	0	\N	0	0	0	0	insulatedcargobay	0	INNER_SPHERE	0	Insulated Cargo Bay
1850d0f8-cc5b-4b45-bef7-0761bcb93fc0	0	\N	0	0	0	0	ladder	0	INNER_SPHERE	0	Ladder
3679a8e1-ea90-4077-b538-caf966a69dd9	0	\N	0	0	0	0	laserrifle(mauseriicias)	0	CLAN	0	Laser Rifle (Mauser IIC IAS)
0e6a1a1c-8104-41e1-b530-46b647685f95	0	\N	0	0	0	0	lifeboat(maritime)	0	INNER_SPHERE	0	Lifeboat (Maritime)
17a6ef48-8aa0-4590-9169-a60f54962bfe	0	\N	0	0	0	0	lightvehiclebay	0	INNER_SPHERE	0	Light Vehicle Bay
5ac95616-7373-406b-ab6d-6b7417665293	0	\N	0	0	0	0	liquidcargobay	0	INNER_SPHERE	0	Liquid Cargo Bay
dff8fbda-1d4b-460a-862f-d65c5b14349c	0	\N	0	0	0	0	livestockcargobay	0	INNER_SPHERE	0	Livestock Cargo Bay
1f0fca3a-72e5-46ce-ab81-330311c5dc2a	0	\N	0	0	0	0	machinegun(semi-portable)	0	INNER_SPHERE	0	Machine Gun (Semi-Portable)
9ca10aab-e11b-4df4-a003-dd6a36ef75ba	0	\N	0	0	0	0	machinegun(support)	0	INNER_SPHERE	0	Machine Gun (Support)
fe6a8511-1084-4e98-8b73-1b5d1b16abb7	0	\N	0	0	0	0	manipulator(non-mech/non-battlearmor)	0	INNER_SPHERE	0	Manipulator (Non-Mech/Non-BattleArmor)
7c5d4b94-5bfd-4bd8-a7a8-c4a6c608934f	0	\N	0	0	0	0	pillionseating	0	INNER_SPHERE	0	Pillion Seating
14b24b94-a14e-4344-9613-0157943edd0d	0	\N	0	0	0	0	pintlemount	0	INNER_SPHERE	0	Pintle Mount
23502b3a-7728-40a7-9504-2c23fd811b6f	0	\N	0	0	0	0	plasmarifle(man-portable)	0	INNER_SPHERE	0	Plasma Rifle (Man-Portable)
f3f02aa5-5d73-4a24-9240-5592d0b1976f	0	\N	0	0	0	0	primitiveprototypeautocannon/20	0	INNER_SPHERE	0	Primitive Prototype Autocannon/20
2267e755-8726-4004-9154-20285eac3fd0	0	\N	0	0	0	0	primitiveprototypeautocannon/20ammo	0	INNER_SPHERE	0	Primitive Prototype Autocannon/20 Ammo
4a6e593e-6c5a-4e42-94df-ef64ab43b5fa	0	\N	0	0	0	0	recoillessrifle(heavy)	0	INNER_SPHERE	0	Recoilless Rifle (Heavy)
b6205be2-59dc-467c-82b1-209e1f93c71a	0	\N	0	0	0	0	refrigeratedcargobay	0	INNER_SPHERE	0	Refrigerated Cargo Bay
8dee4f77-c1d4-4283-8f17-db1155a48ec6	0	\N	0	0	0	0	satelliteimager(high-resolutionimager)	0	INNER_SPHERE	0	Satellite Imager (High-Resolution Imager)
127aae8e-5ac1-4083-9a91-10f414ff0db3	0	\N	0	0	0	0	satelliteimager(infraredimager)	0	INNER_SPHERE	0	Satellite Imager (Infrared Imager)
ba16ffb4-4145-4e8f-873a-5343e82f359c	0	\N	0	0	0	0	searchlight(handheld)	0	INNER_SPHERE	0	Searchlight (Handheld)
e76dd7ad-64dc-4481-8769-0503cb268cc1	0	\N	0	0	0	0	secondclassquarters	0	INNER_SPHERE	0	Second Class Quarters
e8b00e63-7981-40b3-ae99-51edde3e0c21	0	\N	0	0	0	0	sprayer(vehicular)	0	INNER_SPHERE	0	Sprayer (Vehicular)
555c801d-7b65-462c-87a5-bcc5c073acac	0	\N	0	0	0	0	srmlauncher(light)	0	INNER_SPHERE	0	SRM Launcher (Light)
fbc771de-a5d2-424d-8af3-8cef3b34f75a	0	\N	0	0	0	0	srmlauncher(std,two-shot)	0	INNER_SPHERE	0	SRM Launcher (Std, Two-Shot)
744a8a1e-7234-40c2-ae62-fcad4013440c	0	\N	0	0	0	0	standardseating	0	CLAN	0	Standard Seating
b949cb0c-1a18-425e-8646-10ef461de816	0	\N	0	0	0	0	standardseating	0	INNER_SPHERE	0	Standard Seating
2c98c4c9-cfda-438b-9347-82f39ce2ae37	0	\N	0	0	0	0	steeragequarters	0	INNER_SPHERE	0	Steerage Quarters
4117e4fc-6d9d-411e-8441-e6c2c36797a0	0	\N	0	0	0	0	supportlaser	0	INNER_SPHERE	0	Support Laser
4caf75d9-38dd-4f26-b707-0e05f0c72669	0	\N	0	0	0	0	supportlaser(heavy)	0	INNER_SPHERE	0	Support Laser (Heavy)
947c1dde-d730-4bb6-95b4-c121808bb10b	0	\N	0	0	0	0	supportlaser(semi-portable)	0	CLAN	0	Support Laser (Semi-Portable)
0f9f94e4-0bff-4f88-a222-cb47edfb124f	0	\N	0	0	0	0	svchassismod[amphibious]	0	INNER_SPHERE	0	SV Chassis Mod [Amphibious]
ce739ee9-bf5b-447c-88a5-c94018886db7	0	\N	0	0	0	0	svchassismod[bicycle]	0	CLAN	0	SV Chassis Mod [Bicycle]
8975fa49-6f68-461b-b66c-914cd0738b95	0	\N	0	0	0	0	svchassismod[bicycle]	0	INNER_SPHERE	0	SV Chassis Mod [Bicycle]
7579b340-0820-40fc-8354-5bb449a7adf7	0	\N	0	0	0	0	svchassismod[convertible]	0	INNER_SPHERE	0	SV Chassis Mod [Convertible]
725c03ec-7120-4d02-bd5e-d34fa5d68742	0	\N	0	0	0	0	svchassismod[dunebuggy]	0	INNER_SPHERE	0	SV Chassis Mod [Dune Buggy]
5d2c2ead-e6bc-4a9c-8b4d-3ff557faaf72	0	\N	0	0	0	0	svchassismod[hydrofoil]	0	INNER_SPHERE	0	SV Chassis Mod [HydroFoil]
f3dc337b-dffb-44c7-8acf-19ad9c2470e3	0	\N	0	0	0	0	svchassismod[monocycle]	0	INNER_SPHERE	0	SV Chassis Mod [Monocycle]
b7de8358-2af0-4b1e-a92f-a209cbef1421	0	\N	0	0	0	0	svchassismod[omni]	0	CLAN	0	SV Chassis Mod [Omni]
3acd81f7-0eb0-40ad-bce4-29ef4db670f9	0	\N	0	0	0	0	svchassismod[omni]	0	INNER_SPHERE	0	SV Chassis Mod [Omni]
02c1dd4f-3152-4d33-b481-90a67b0a2759	0	\N	0	0	0	0	svchassismod[snowmobile]	0	INNER_SPHERE	0	SV Chassis Mod [Snowmobile]
15b2741a-1769-495c-92d8-e34c1df3fbb6	0	\N	0	0	0	0	svchassismod[submersible]	0	INNER_SPHERE	0	SV Chassis Mod [Submersible]
05ffc8a6-37d9-48db-952c-646391467733	0	\N	0	0	0	0	svchassismod[tractor]	0	INNER_SPHERE	0	SV Chassis Mod [Tractor]
042f7172-e909-4451-87dc-cb9018a4215a	0	\N	0	0	0	0	svchassismod[trailer]	0	INNER_SPHERE	0	SV Chassis Mod [Trailer]
c9c30a19-94d6-48b4-9d69-8a9098f8735f	0	\N	0	0	0	0	svchassismod[ultra-light]	0	INNER_SPHERE	0	SV Chassis Mod [Ultra-Light]
b53db2d1-3695-4da1-a076-ce0292498cb8	0	\N	0	0	0	0	tag(light,man-portable)	0	INNER_SPHERE	0	TAG (Light, Man-Portable)
e45f2f89-d918-4281-9bf4-e96195840efe	0	\N	0	0	0	0	wire-guidedmissilelauncher	0	INNER_SPHERE	0	Wire-Guided Missile Launcher
\.

INSERT INTO equipment
SELECT v.* FROM v3_22_equipment v
WHERE NOT EXISTS (SELECT 1 FROM equipment e WHERE e.name = v.name AND e.tech IS NOT DISTINCT FROM v.tech);

-- 2.
COPY v3_22_unit (dtype, id, designation, era, bonus_jump, jump, potential_run, potential_walk, run, walk, name, omni, rules_level, tech, weight, weight_class, ejection, heatsink_quantity, tech_type, type, locomotion, myomer, megamek_uuid, mul_id, motive_system, engine_type, engine_tech, engine_rating, armor_type, armor_tech, structure_type, structure_tech, gyro, cockpit, lam_type, quad_vee_motive) FROM stdin;
SupportTank	9827aeb8-a823-49c4-abac-de4368aff617		\N	0	0	0	0	0	11	Air Car	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e231-73a2-9055-f7d8459e4f09	3684	Hover	ICE	INNER_SPHERE	440	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3fc42f48-58ae-450b-8da4-7b0c36cfba82	(NapFind)	\N	0	0	0	0	0	15	Hi-Scout Drone	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e29c-762f-9274-753bb6064e76	1530	Hover	FUEL_CELL	INNER_SPHERE	38	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	76be8b29-4713-4633-89f1-3adf2d57f12e	(PathTrak)	\N	0	0	0	0	0	8	Hi-Scout Drone	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	1531	Tracked	ICE	INNER_SPHERE	24	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	61ca47d4-1962-45c3-a59b-a9bd17f29a9d	(Cargo)	\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e649-77d4-ab78-f95b76a11762	5475	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	af0e8a5c-ccc0-4a92-9a6a-c1e122a568e4	(Reverse)	\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e64b-79ec-a027-ca5b2431f0d9	5476	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6a7403b1-a068-4470-95c7-5342395a54ba		\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e64d-79ff-af8b-7dd38cde63fd	5477	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	eeadca31-eecb-4901-aed5-2e6844bba80e		\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VIII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e650-7bd6-a664-8080fffc751a	5478	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	be7d6cf2-2160-451c-8d49-3208ed772bec		\N	0	0	0	0	0	2	Dromedary Water Transport	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e653-7a8c-a667-4b6b66b73922	4099	Wheeled	ICE	INNER_SPHERE	300	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e89082cc-25f7-4a77-8dd7-d40ed1b6a55a	DeConAid Trailer	\N	0	0	0	0	0	0	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e654-7265-b77a-515a1e7450b2	6961	Tracked	NONE	INNER_SPHERE	0	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	05c55530-5bbe-453e-b875-0f1d4d3887a2	'Oppie' O-65	\N	0	0	0	0	0	2	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e656-7f3e-8c83-5133b1d91814	4739	Tracked	FUSION	INNER_SPHERE	300	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cb913297-fdde-42f8-8f65-a1222e6f6919	'Oppie' O-66	\N	0	0	0	0	0	2	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e659-75cf-af7e-617b624a12ff	4740	Tracked	FUSION	INNER_SPHERE	300	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	55c6d801-bb98-49ba-bf05-345206d0f0d5	Salvage Bed	\N	0	0	0	0	0	0	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e65c-7589-805d-1f76e53fc17c	6960	Tracked	NONE	INNER_SPHERE	0	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3f5ba66e-30c7-4c33-9ced-bd2e1e0af70a	JI-50 (Hoist)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e66a-7f62-809c-937110fabc1b	4405	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6c3cf350-3f4a-4c7a-bd27-b257a581cc48	JI-50 (MG)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e66e-7939-9125-398d08c4c0f2	4404	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d60132a1-ffd0-458a-a874-f08dafc80cd1	JI-50 (ML)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e670-7c82-aa18-a995e6e33753	4406	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	75fb38a2-e08d-484d-b933-c90d1af50a3d	JI-50 (Q-Vehicle)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e671-7d35-b57b-ba79e8093ccc	4407	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	328677f9-eb02-4a0c-a05c-d8e2acd5f6a3	JI-50	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e674-72a3-b6e4-69c5b17f3a1e	4403	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	23eb411c-b1db-4a25-ae86-e03d286425e7	Mk VII	\N	0	0	0	0	0	3	Merkava Heavy Tank	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e67a-754c-87ea-c8e670768c1e	4628	Tracked	FUSION	INNER_SPHERE	225	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5769131b-f249-4fba-ab37-059d3c25a9e4	(MFB)	\N	0	0	0	0	0	4	Paramour Mobile Repair Vehicle	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e67b-784c-9db5-d6ce76f2fd2c	4788	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6a567e04-b0bb-41aa-a82b-3d5024b0da3a		\N	0	0	0	0	0	4	Paramour Mobile Repair Vehicle	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e67e-781a-8912-e1f77ce45fac	4789	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	56360aff-1884-4b83-95e5-da0eb2d099f1		\N	0	0	0	0	0	3	Prometheus Combat Support Bridgelayer	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e688-7bca-a9c5-5ca6c628192e	4872	Tracked	FUSION	INNER_SPHERE	225	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4fd39cea-3b49-4ae0-9e43-d94e59337f6b		\N	0	0	0	0	0	3	Nifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e68b-75cf-a396-5b8b997fd55f	4716	Tracked	ICE	INNER_SPHERE	180	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b63d8b88-5650-41ea-85b8-614d411fb341	A3	\N	0	0	0	0	0	3	Augustus MBT	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e690-77ea-9b93-91c5ffe79fac	154	Tracked	ICE	INNER_SPHERE	225	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2d808fb7-0294-4154-9e1e-55f0605201f4	(Original)	\N	0	0	0	0	0	5	J-37 Ordnance Transport	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e6e0-7b06-a615-2b2abbb88cd6	1648	Wheeled	FUSION	INNER_SPHERE	250	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	67acd9dd-6e40-4b6b-812d-b9a5b30ddde0		\N	0	0	0	0	0	5	J-37 Ordnance Transport	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e6e2-7e3e-99a0-16496db45d28	1649	Wheeled	FUSION	INNER_SPHERE	250	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	0414fa6d-1ba5-4350-b6aa-832f1e9088f5		\N	0	0	0	0	0	6	Tonbo Superheavy Transport	f	0	INNER_SPHERE	56	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e727-7a8f-9e84-a4b0c69276a5	3275	\N	FUSION	INNER_SPHERE	336	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8a6fadfc-84f7-4368-b8cd-9664217052b2	(CS)	\N	0	0	0	0	0	7	Trireme Infantry Transport	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e72f-707b-a00a-560fe7270860	3308	\N	FUSION	INNER_SPHERE	420	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	7c3ae4bb-7199-480a-9d1f-0c25e7e9430e		\N	0	0	0	0	0	6	Trireme Infantry Transport	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e731-7888-8c39-b99da4acf787	3309	\N	FUSION	INNER_SPHERE	360	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	e31b55f3-830d-47eb-98d6-2641b26dbcf9		\N	0	0	0	0	0	7	Bishop Transport VTOL	f	0	INNER_SPHERE	45	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e806-7a90-a05e-960ee185f5a1	6545	\N	FUEL_CELL	INNER_SPHERE	315	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	89c4403f-e47d-4f19-b8f7-9a751de931af		\N	0	0	0	0	0	4	Savior Repair Vehicle	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e813-7306-bd3b-30e5dfae7622	6546	Tracked	FUSION	INNER_SPHERE	240	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6bfa5a5d-cccc-42dc-9fd1-8772b4701f23	A	\N	0	0	0	0	0	14	Boreas Cavalry Hovercraft	t	0	CLAN	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8c7-75f1-8d54-551bf09a0730	9218	Hover	FUEL_CELL	INNER_SPHERE	11	BAR_8	CLAN	STANDARD	CLAN	\N	\N	\N	\N
SupportTank	cf5741d8-533f-42c3-8036-eef1bec5ba67	B	\N	0	0	0	0	0	14	Boreas Cavalry Hovercraft	t	0	CLAN	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8c9-7cbe-a88f-62c6e42329ad	9219	Hover	FUEL_CELL	INNER_SPHERE	11	BAR_8	CLAN	STANDARD	CLAN	\N	\N	\N	\N
SupportTank	00f141dd-a6c0-4940-9ca8-592e880267d3	(Prime)	\N	0	0	0	0	0	14	Boreas Cavalry Hovercraft	t	0	CLAN	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8cb-7c3a-9c9e-7a217b4325d3	9217	Hover	FUEL_CELL	INNER_SPHERE	11	BAR_8	CLAN	STANDARD	CLAN	\N	\N	\N	\N
SupportTank	271f80f9-33e8-49d5-9325-51395b417540		\N	0	0	0	0	0	9	Hoodling Sensor HoverJeep	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8cd-79f5-ac82-f89dfc20dbee	9220	Hover	FUSION	INNER_SPHERE	45	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9c706a0f-6dff-42db-908d-6b472414fbed		\N	0	0	0	0	0	5	HoverPod	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8cf-7c27-b0c7-b3c22c44e45a	9221	Hover	BATTERY	INNER_SPHERE	1	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6028cbb3-20f7-431a-bb01-eec651ea42af		\N	0	0	0	0	0	10	JI-002 HoverBike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d0-7cae-9e0c-25c7f6e835bf	9222	Hover	BATTERY	INNER_SPHERE	7	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	78f25add-b81e-4834-a3e6-1a1fdd81ba00		\N	0	0	0	0	0	3	Harpoon ParaSub	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d2-7000-a8c2-9e2a44f5ae51	9230	Submarine	FUEL_CELL	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	81f116ee-0aaa-4c25-a79e-d1eb062b7440		\N	0	0	0	0	0	2	Small Steamer	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d4-7f7c-9235-fa32872c784e	9231	Naval	STEAM	INNER_SPHERE	5	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	2b3f1628-8831-416f-87b8-2a64cc610104		\N	0	0	0	0	0	5	HTE Micro-Copter	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d6-7df9-8874-e3dab445ead1	9229	\N	ICE	INNER_SPHERE	0	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	18784556-c8b0-4b2f-a2f3-3e229f559d67		\N	0	0	0	0	0	6	Assuan Armored Bike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d8-7171-9fd0-4da83cb95ff1	9223	Wheeled	ICE	INNER_SPHERE	6	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bd3db561-6673-481a-bd45-f9bd5ad99ce2		\N	0	0	0	0	0	3	Beast Riot Car	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d9-715d-abd9-9da2e9f5bc2f	9224	Wheeled	FUSION	INNER_SPHERE	12	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	833add70-388d-4b3a-b5d1-8b13af35b15b		\N	0	0	0	0	0	10	Death Trike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8da-7f95-b3ef-20609635092b	9225	Wheeled	ICE	INNER_SPHERE	6	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	82df9f51-d7c5-4da0-aa87-fe9155f9961d		\N	0	0	0	0	0	8	Dune Buggy	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8dc-72eb-906e-b0b726970333	9226	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a2e81895-b295-4f1c-9d28-07c8c867a6b2		\N	0	0	0	0	0	5	Eagre Firefighting ATV	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8dd-766f-9b54-3ee51394b3f1	9227	Wheeled	BATTERY	INNER_SPHERE	4	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9bcb761b-0c0a-4dbd-bf26-5e020ffe0914		\N	0	0	0	0	0	4	Tracked Quad	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8df-7489-87be-783213e374a7	9228	Tracked	ICE	INNER_SPHERE	9	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	792c7a84-8048-4c66-a712-c87546c841e6		\N	0	0	0	0	0	4	Shackleton AESV	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e8e0-7156-b045-bfaa36119249	5800	Wheeled	FUSION	INNER_SPHERE	200	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	37c7cc45-2e58-42aa-a50a-dcf627e40ae4	(Anti-Aircraft)	\N	0	0	0	0	0	3	Estevez MBT	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e8e1-7dce-aea0-a3d6b48c0c03	4138	Tracked	ICE	INNER_SPHERE	240	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4f31e391-4459-4726-aee0-7b676991d92a		\N	0	0	0	0	0	3	Estevez MBT	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e8e5-7b3c-add5-107849771830	4139	Tracked	ICE	INNER_SPHERE	240	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a0952477-552a-424c-84d6-c13ef1176b7e	I	\N	0	0	0	0	0	3	Marsden MBT	f	0	INNER_SPHERE	65	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	4602	Tracked	ICE	INNER_SPHERE	195	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	82047670-e6d1-4182-8e7d-22e09472a19f		\N	0	0	0	0	0	4	Apocalypse World Rover	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f4-7564-9283-eef7d59681c3	3705	Wheeled	ICE	INNER_SPHERE	8	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	07f988ed-5774-44d2-9471-9f0862ce3332	(Command Post)	\N	0	0	0	0	0	6	Generic Expandable Services Vehicle	t	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f6-7734-b7fd-8bec3772bda2	9582	Wheeled	FUEL_CELL	INNER_SPHERE	180	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1e98629d-1e14-4a44-9edc-dc128c53b1e6	(Field Kitchen)	\N	0	0	0	0	0	6	Generic Expandable Services Vehicle	t	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f7-7f4d-b7a0-d300976b8c70	9583	Wheeled	FUEL_CELL	INNER_SPHERE	180	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6e965feb-43a5-4631-9a54-541179a1ea8d	(MASH)	\N	0	0	0	0	0	6	Generic Expandable Services Vehicle	t	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	9585	Wheeled	FUEL_CELL	INNER_SPHERE	180	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9cb6c49e-a66c-4834-8287-5a020abb081c	(Bunk)	\N	0	0	0	0	0	0	Generic Expandable Services Vehicle Trailer	t	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8fa-705c-a86e-641d91a256aa	9586	Wheeled	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bd3d773d-7a56-4416-9eab-f970991729fa	(Cargo)	\N	0	0	0	0	0	0	Generic Expandable Services Vehicle Trailer	t	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8fc-7622-afeb-8df8291b40c6	9587	Wheeled	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e569b14d-58c9-4220-9c79-22df9eb748cd		\N	0	0	0	0	0	4	Heavy Combat ATV	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8fd-7e7e-a398-e9a547d14830	4831	Wheeled	ICE	INNER_SPHERE	2	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6a0c8031-547a-4427-8b50-5ab061259df8		\N	0	0	0	0	0	5	Obuzaabaa Tactical Vehicle	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8ff-7c25-89b0-57a8dae3ae7d	7771	Wheeled	FUEL_CELL	INNER_SPHERE	125	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b20d25cf-3a3e-4256-88cb-888e598e582b		\N	0	0	0	0	0	5	Sasayaku Control Transport	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e900-7dd6-97b8-dcea7bba7a3e	7772	Wheeled	FUEL_CELL	INNER_SPHERE	125	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	5e6a4205-fcd8-4d53-bf7f-8645990f4479		\N	0	0	0	0	0	7	Apple-Churchill Surveillance VTOL	f	0	INNER_SPHERE	20	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e902-71ce-9cc5-05cb327cd5c8	3708	\N	ICE	INNER_SPHERE	140	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	59a73a1e-700f-4106-99d0-d5cc473d6d2f		\N	0	0	0	0	0	11	C-85 Sprinter Delivery Vehicle	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e904-79eb-b552-460ed6242c3c	3931	Wheeled	BATTERY	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	efda2d18-cd39-4ece-a471-8610d81cb23b		\N	0	0	0	0	0	4	Hector Road Train Tractor	f	0	INNER_SPHERE	160	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e906-700d-b94b-51df5ac8b568	4285	Wheeled	ICE	INNER_SPHERE	500	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	45219a36-516f-425a-91a8-7db37fc05955	(Liquid)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e907-7d40-b85a-70a5c8b4fc5f	4287	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9c74524a-6434-4148-998c-1b3aefdda931	(Livestock)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e90a-7725-ae3b-6fd6beb2e32d	4288	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	34787716-1aa7-43e9-8807-79937ef0d87b	(Passenger)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e90d-750f-82f4-4ae3cd916c2a	4289	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8d714704-6ca0-424f-8ead-42a6d2ef9447	(Refrigerated)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e90f-72ae-873e-3d4014ac2ff3	4290	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c23e2558-b9d0-4200-87f5-d65df1b22a63		\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e910-7643-8852-814c6e90b4f0	4286	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0cc5c0e7-13ed-4573-a698-d9bd02e0176d	(Militarized:Gauss)	\N	0	0	0	0	0	5	Ibex RV	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e913-7389-a648-0624c05f2f44	4355	Wheeled	ICE	INNER_SPHERE	10	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7f82c41e-cdbe-42a6-8069-ac56c99fc900	(Militarized:MG)	\N	0	0	0	0	0	5	Ibex RV	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e914-7693-8724-943128800a78	4356	Wheeled	ICE	INNER_SPHERE	10	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c0f3c742-296e-4408-8663-6835f7c6b680		\N	0	0	0	0	0	5	Ibex RV	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e915-7783-b5dc-1e16b1dfac0c	4357	Wheeled	ICE	INNER_SPHERE	10	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	61e5e31c-bc31-420a-860b-1010e84c6a93		\N	0	0	0	0	0	3	Wayland Mobile Base	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e92c-7ea8-8f09-e39bc182cda4	5396	Tracked	FUSION	INNER_SPHERE	450	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5e7afd6c-888a-4938-bb69-548b57cb7bd3	(AC)	\N	0	0	0	0	0	3	Brunel Dump Truck	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e935-70b2-ba3e-07e18e7145bf	3864	Wheeled	ICE	INNER_SPHERE	450	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	02fa962a-65a5-4d2c-998b-c94ddf333b8d	(LRM)	\N	0	0	0	0	0	3	Brunel Dump Truck	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e937-74b5-b408-3a549695a9ad	3865	Wheeled	ICE	INNER_SPHERE	450	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	25dae16b-a605-4f24-aa48-1a0ad42dcc54	(Production)	\N	0	0	0	0	0	12	Lexan Surveillance VTOL	f	0	INNER_SPHERE	17	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e962-7b51-a87b-cc6ad71000e3	4506	\N	FUSION	INNER_SPHERE	204	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9516ce11-c6e8-458a-aa90-7ca3f526f5de	Koi	\N	0	0	0	0	0	5	Nishikigoi Support Aircraft	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e965-724d-8c86-a8e46210b74e	4728	WiGE	FUSION	INNER_SPHERE	500	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cd5e2729-7518-4180-ba7c-eb17e2ceea11	ADT-1	\N	0	0	0	0	0	3	Auxiliary Defense Tank	f	0	INNER_SPHERE	28	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea5f-7925-92e7-611ca0aba32a	8302	Tracked	ICE	INNER_SPHERE	84	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	40d885b4-36c3-4b58-b30f-d5f0d5352cdc	ADT-2	\N	0	0	0	0	0	3	Auxiliary Defense Tank	f	0	INNER_SPHERE	28	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea61-7566-870b-5ed3a47568d4	8303	Tracked	ICE	INNER_SPHERE	84	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	61d3a7a5-f944-41d5-a1dc-3a9dd3394020	'The Warcrime Wagon'	\N	0	0	0	0	0	2	Debbie	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ea62-7318-978c-0befea421dfe	7630	Tracked	ICE	INNER_SPHERE	160	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6148d18d-228e-4b51-a661-22cc45da008f		\N	0	0	0	0	0	5	Outrider	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea64-7933-93eb-c6be11ec1aee	7631	Wheeled	ICE	INNER_SPHERE	8	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8303995b-4a75-42e0-9dc2-7912d96e0eb8	(Laser)	\N	0	0	0	0	0	12	Hoverbike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea65-73df-9d60-09bb7587ad94	7808	Hover	FUEL_CELL	INNER_SPHERE	14	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	02d2ade7-ae85-41b4-a2b7-012943815d1c	(MG)	\N	0	0	0	0	0	12	Hoverbike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea67-7d08-ac7f-4b1ab3191905	7809	Hover	FUEL_CELL	INNER_SPHERE	14	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c8f9beee-97fa-470b-8fe0-7a9648623107		\N	0	0	0	0	0	12	Hoverbike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea68-7726-b719-e46c85a620fb	7807	Hover	FUEL_CELL	INNER_SPHERE	14	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	538e303a-627a-49db-a120-bd07743e25db	(SRM)	\N	0	0	0	0	0	7	Minigun Cycle	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea69-7bcf-a185-c649f8b45549	7806	Wheeled	ICE	INNER_SPHERE	2	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4677b164-2bf6-4a39-bbda-653c060682a3		\N	0	0	0	0	0	7	Minigun Cycle	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6b-782e-86af-f4cc09cc6486	7805	Wheeled	ICE	INNER_SPHERE	2	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a0131902-32ff-4d96-8a61-53d222ba4005		\N	0	0	0	0	0	8	Monocycle	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6c-766b-981f-bb4533825ff3	7804	Wheeled	ICE	INNER_SPHERE	6	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2a54b932-a094-4d8b-af09-ff28246c56dd		\N	0	0	0	0	0	9	Scout ATV	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6e-73c2-b2b0-abe409e92816	7812	Wheeled	ICE	INNER_SPHERE	9	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ad1af7c5-dcdf-4ce6-ad8d-6312fab6761a		\N	0	0	0	0	0	7	TrackBike	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6f-75d3-bc85-8bf53c79276b	7811	Tracked	ICE	INNER_SPHERE	14	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8fdac0e6-fc82-4d1a-89a8-f82f95306492		\N	0	0	0	0	0	6	Trike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea70-7299-ac6b-32f4589a1a2b	7810	Wheeled	ICE	INNER_SPHERE	3	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d9de9c83-1af1-40b0-b19f-b773c764ddb7	(Original)	\N	0	0	0	0	0	5	Prime Mover	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ea72-7df4-ae4c-b8f07fdc593c	7817	Wheeled	FUSION	INNER_SPHERE	300	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0bba4dab-d7d1-425c-aa2d-74b74c5d1bb6	(Succession Wars)	\N	0	0	0	0	0	5	Prime Mover	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ea73-773c-bc0b-7353d654d9bd	9512	Wheeled	FUSION	INNER_SPHERE	300	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	acd7629f-9ed0-465b-a46a-7219d54aea51	(LRM)	\N	0	0	0	0	0	5	Prime Mover	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ea75-7bc0-9f24-7cec82d88f2b	7818	Wheeled	FUSION	INNER_SPHERE	300	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1256f2ad-ca36-4acf-b994-aa92916d52a4	WiGE	\N	0	0	0	0	0	8	Sturmvogel Gunship	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea77-752e-ad84-382cf20495b3	7816	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1501cfd9-87a0-4dee-9ebe-06a4174aceef	(LB-10X)	\N	0	0	0	0	0	8	Sturmvogel Maritime Patrol WiGE	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea7b-7248-939c-265f761f0fb2	7815	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0d5fe60b-41c6-4b6a-bdc3-16e78dd0215c	(LB-2X)	\N	0	0	0	0	0	8	Sturmvogel Maritime Patrol WiGE	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea7e-7b02-a9cc-19f319098488	7814	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5bff3a43-a00c-4012-9ca9-355e02c9f918		\N	0	0	0	0	0	8	Sturmvogel Maritime Patrol WiGE	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea80-7b1e-928e-5ed05d07c074	7813	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	541efee6-de5f-4302-ac82-08c3c299f751		\N	0	0	0	0	0	12	Bayamo Hoverbike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea89-74fd-bbf9-2c328cd2bafd	3810	Hover	BATTERY	INNER_SPHERE	7	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cae494be-bca6-4ea3-9a93-31b498323d92	BFFL Hovertruck	\N	0	0	0	0	0	5	Buffalo	f	0	INNER_SPHERE	100	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ea8d-71ba-ada3-c4e412cb9fd2	3819	Hover	FUEL_CELL	INNER_SPHERE	500	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	12118d0d-0353-4b8b-88cd-0b02398ee471		\N	0	0	0	0	0	15	Champion Hoversports CS535 Hover Car	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea8f-7da6-8321-6f2f6dbbbc80	3942	Hover	ICE	INNER_SPHERE	45	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1a72073e-f772-4c16-9043-d6db3e842fa5		\N	0	0	0	0	0	17	Champion Hoversports Crimson Streak Hover Racer	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea91-7849-8b93-ca87e63a1f10	3941	Hover	FUEL_CELL	INNER_SPHERE	60	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	687e7437-a5a8-4a3a-a9f5-6a95f3b3d9b6		\N	0	0	0	0	0	7	Deusenberg VIP Luxury Hovercar	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea94-79a8-a982-ec2a2a88d9d6	4074	Hover	FUSION	INNER_SPHERE	350	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c19f9638-e9ec-4dca-9e0f-319cb3dcee22	(Original)	\N	0	0	0	0	0	7	Deusenberg VIP Luxury Hovercar	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea97-7e69-b5a0-da6c266d4fb4	4073	Hover	FUSION	INNER_SPHERE	350	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	548f07aa-870d-406a-a4a5-c0e58ad06f3d		\N	0	0	0	0	0	7	Dillinger Police Vehicle	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea9a-76d8-8101-7d4068cefc55	4464	Hover	FUSION	INNER_SPHERE	280	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	97ca3b8b-089c-4d97-9059-1e86d56d7667		\N	0	0	0	0	0	10	Freedom 900 Hover Jeep	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea9d-76b7-99cd-2165b9e79aab	4187	Hover	ICE	INNER_SPHERE	30	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7ce524be-3877-42b7-b3f1-b9c3b151eed7		\N	0	0	0	0	0	9	Ina-du Swamp Skimmer	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea9f-756b-a692-9527ec3fc049	4361	Hover	FUEL_CELL	INNER_SPHERE	90	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c73c37bc-9487-44a5-91ec-8b36292d89cf		\N	0	0	0	0	0	6	Lewis Skimmer Bus	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-eaa2-7bd2-93a2-4c8ebd3527eb	4503	Hover	FUEL_CELL	INNER_SPHERE	480	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	302f9f45-e082-497e-9135-0df0117d6b89		\N	0	0	0	0	0	9	Routemaster Hover Shuttle	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaa3-7d11-b1a0-aec3057334d2	4944	Hover	ICE	INNER_SPHERE	34	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	24d5d98d-05f7-4b55-bdef-8f7dbb4e94fe		\N	0	0	0	0	0	15	Slipper Hovercar LX-Series	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaa5-7454-8517-0af434784a6e	5080	Hover	FUEL_CELL	INNER_SPHERE	23	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	40eadea7-f1c9-45e6-b20f-3c73c7c96ef8		\N	0	0	0	0	0	3	Baleena Passenger Submarine	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaa8-7004-b1f7-cfbb94817579	3778	Submarine	FUSION	INNER_SPHERE	500	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0550bc49-6fb3-4761-898e-dbe181492d33	JN-002	\N	0	0	0	0	0	4	Jonah Submarine	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaaa-76f7-b7e6-989e6480a13e	4408	Submarine	FUSION	INNER_SPHERE	8	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a31c64af-51cb-4968-9882-519d7130b95f		\N	0	0	0	0	0	4	Seahorse Cargo Sub	f	0	INNER_SPHERE	250	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaac-74d2-9629-c1f2eb661366	5011	Submarine	ICE	INNER_SPHERE	500	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	efed2acf-734d-4149-aef6-fb808d2d670d		\N	0	0	0	0	0	3	Atlantia Luxury Yacht	f	0	INNER_SPHERE	190	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaaf-7c92-b5ff-4b6f4765efb3	3748	Naval	ICE	INNER_SPHERE	500	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b320ceb0-59d0-4b51-b5f2-83d8f9cae15c		\N	0	0	0	0	0	6	Silverback Coastal Cutter	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eab1-7d75-8413-9dce41e11ead	5062	Hydrofoil	ICE	INNER_SPHERE	240	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b5fa1fa2-068f-4616-8cf5-c493f16542a3		\N	0	0	0	0	0	6	Silverfin Coastal Cutter	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eab4-7121-a296-3d6a5868bf90	5063	Hydrofoil	ICE	INNER_SPHERE	240	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	31711bf8-744c-48e5-b52b-395d45d35cdb		\N	0	0	0	0	0	7	Whitestreak Jetski	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eab7-7393-aaa2-212bbb5a8a3a	5407	Naval	FUEL_CELL	INNER_SPHERE	1	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	37ebcd05-57f6-4b63-be70-a172793ae833		\N	0	0	0	0	0	12	Whitestreak Speedboat	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eab9-7eb7-92ce-33119b5fd7a6	5408	Naval	FUEL_CELL	INNER_SPHERE	3	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	98c35be8-8c31-4ddd-ba80-f6c4e75e17fd		\N	0	0	0	0	0	12	Adelante Passenger/Cargo Train	f	0	INNER_SPHERE	600	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaba-77cc-bbc6-e0ce02cb8ced	3669	Rail	FUSION	INNER_SPHERE	500	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8e556208-6b2b-4473-bb4a-4c78035ec99a	A (Passengers)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eabe-7fb3-a5fd-7786e7c0c045	5214	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	959024d3-f7ef-44fc-bd90-24309743b78f	B (Military Support)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eac1-7290-a30c-99fa10f3558c	5214	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	50a31ca8-9d84-4584-98db-2ae6cd799b51	C (Cargo)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eac4-72c9-be12-f0862f962a4e	5215	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7d470a61-f1b8-4e3e-93cb-c636d4ed38f0	D (MASH)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eac8-7be2-a548-c275acaa1e23	5216	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d3497a7e-1eeb-4b2c-8be6-535882723a6b	Primary (Luxury)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ead9-788f-9051-cd4db6b63371	5217	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8adfff12-9400-4c03-8896-b714744bac27	Primary Configuration	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eadc-75eb-992c-2dc58ce46ff1	5217	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9a5db772-f84e-4265-8016-1846b903446e	UPU-3000	\N	0	0	0	0	0	3	Cellco Ranger	f	0	INNER_SPHERE	17	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eadf-700b-aece-62f18cdb6b58	3915	Tracked	ICE	INNER_SPHERE	51	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e5d9677a-8136-40d0-b2ee-0b7f5fd67e9f		\N	0	0	0	0	0	1	Corx Mobile Tunnel Miner	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eae4-7240-bf52-9ce4d3d2aec0	4011	Tracked	FISSION	INNER_SPHERE	200	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1adcf4e7-fb81-4aec-b5f9-99b97019b7ca		\N	0	0	0	0	0	2	Croyle Systems Cortez Series N	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eae7-73ca-8e85-fe2aba846ce5	4027	Tracked	FUSION	INNER_SPHERE	150	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0917e70d-6b7d-48d0-954a-79ec95290a9f		\N	0	0	0	0	0	0	Galaport Ground Trailer	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaec-7b17-9b33-5c0e62d441c3	4196	Tracked	NONE	INNER_SPHERE	0	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4b78abf1-b3e6-4aa5-bbb3-ee1dcaedac60		\N	0	0	0	0	0	2	Galaport Ground Tug	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaee-7a62-b46b-a0cfb832b36d	4195	Tracked	FUSION	INNER_SPHERE	400	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	db94fa86-bbae-45d0-a00d-97597e4a9e6f	(Tractor) Series 3	\N	0	0	0	0	0	4	Gienah-Durapaq Elite Land Train	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaf1-7d35-86c5-5791aa3d7f1b	4211	Tracked	FUSION	INNER_SPHERE	500	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fb5d3dcd-6c89-4e53-aa4d-938b86321f47	(Trailer) Series 3T	\N	0	0	0	0	0	0	Gienah-Durapaq Elite Land Train	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eaf4-7edb-81b9-282313c635d6	4212	Tracked	NONE	INNER_SPHERE	0	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7a8126cd-53ff-4ef2-af57-cebf303e70ae	B (Bulldozer)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaf7-7245-bcb6-562f0f692e6b	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	63a5878c-c4d5-4293-9ef9-0df8195f41f3	Prime (Cargo)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eafa-7f5e-9b91-9392b84cb84b	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a3cbdb60-5499-4f55-8827-7d55fa9bf225	C (Crane)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eafd-7785-87d2-d7d036befb00	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d236296f-415c-48a7-b526-a4251f56f3e3	A (Harvester)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaff-7230-9148-e755ed804af8	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2eca4e3e-8c07-4940-b2d2-325addcba6a2	UL-10 'Backhoe'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb03-725e-a7ac-16ddedab3c01	4423	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f31e5971-66fc-46b0-9bf9-240a4a62d8f6	UL-11 'Rock Cutter'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb05-765f-aa7d-dab58755008d	4424	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f7eb8b42-4c78-46cd-b788-11262988b271	UL-12 'Chainsaw'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb08-735e-97aa-af93f7f2e9dc	4425	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5c84e80f-00a2-4bf2-887f-7bdbfd81fdd0	UL-14 'Dual Bulldozer'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb0a-7c22-b52d-cb72caf6e6af	4426	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d5480659-ba69-4211-8587-679abe9d02fe		\N	0	0	0	0	0	2	Limpet Half-Track	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb0e-7b5f-afa0-b120634189cc	3869	Tracked	FUEL_CELL	INNER_SPHERE	8	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	73e95044-cfbb-4e41-b6c2-6d320439370d		\N	0	0	0	0	0	4	Luciano White Wolverine	f	0	INNER_SPHERE	8	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb12-74db-b53b-5eef739e6955	4540	Tracked	ICE	INNER_SPHERE	32	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	015ec7ed-cf1c-430e-889f-77e3235d2099		\N	0	0	0	0	0	2	Magellan Series Four	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb16-7869-91f5-649ee5124434	4088	Tracked	FUEL_CELL	INNER_SPHERE	150	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8f1c8187-3b18-471f-8c1b-7aa88c096768		\N	0	0	0	0	0	4	Raptor RRV	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb19-70e7-944f-06e94c2fb2b5	4900	Tracked	FUEL_CELL	INNER_SPHERE	60	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8f4ac74d-632b-4414-a273-465d76eb0317	RRV	\N	0	0	0	0	0	2	Rock Rover Half-Track	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb1c-7f90-b0d5-d9443332c6d7	4946	Tracked	FUEL_CELL	INNER_SPHERE	8	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	531f0459-f4e2-42f5-bd7c-2a53afc458b3	RRV (Speed)	\N	0	0	0	0	0	3	Rock Rover Half-Track	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb1f-703a-830f-682569c85ac8	4945	Tracked	FUEL_CELL	INNER_SPHERE	12	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b5eff6f8-b1bc-487c-8749-947a8ded99bc		\N	0	0	0	0	0	2	Rumbler-HT	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb24-79d8-92d8-73b427772b18	4210	Tracked	FUEL_CELL	INNER_SPHERE	6	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ba955913-f7a8-48b1-988f-01c3f84dfe8d		\N	0	0	0	0	0	2	Saturn Harvester	f	0	INNER_SPHERE	175	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb28-7e35-923c-431fd9d1c460	4977	Tracked	FUSION	INNER_SPHERE	350	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ee828a13-88ec-448f-8d26-cb6ee6713185	(MASH)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb2c-7dd0-b55a-dbea0e342200	5047	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4718cf9b-077f-46d5-8699-5898511eee68	(Mobile Canteen)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb30-759d-95a9-e212f7dc9c00	5049	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a968ac16-7239-4c64-a1e8-8b6b15626754		\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb33-74f7-b789-45c38ab4bd89	5050	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	1a501c23-d10a-444b-a545-10f1ee5ca361		\N	0	0	0	0	0	8	Blackstone Baronet Passenger VTOL	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb36-7f04-b382-7da6a3064956	3832	\N	FUEL_CELL	INNER_SPHERE	400	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	66a903e8-f64f-4ed7-85a4-420be72342e7		\N	0	0	0	0	0	8	Blackstone Pegasus Passenger VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb38-7c8e-9913-22a6dd885e82	3833	\N	FUEL_CELL	INNER_SPHERE	240	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	cbbc3189-e4aa-48a0-9939-23e38aeea837		\N	0	0	0	0	0	6	Cascatelle Firefighting VTOL	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb3a-748f-a3dc-0eab4dba3cbe	4833	\N	ICE	INNER_SPHERE	360	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	af23a6ce-aa2f-43b4-b96b-2af2a9c5bfb6	Series VI	\N	0	0	0	0	0	5	Lexan Oceanic Luxury VTOL	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb3f-7e01-a045-dbf4fd922f5d	4504	\N	FUSION	INNER_SPHERE	300	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	53fae4a5-ef02-4594-8b8c-40f2c2e5a40e	Series II	\N	0	0	0	0	0	15	Lexan Oceanic Personal VTOL	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb42-7c1d-a49d-982cbe3e7171	4505	\N	FUSION	INNER_SPHERE	225	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	75502994-2586-4944-826a-2baa7de3ce4f		\N	0	0	0	0	0	7	Peacekeeper SWAT Carrier	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb45-7948-a8bc-23d7e8efdfbc	4796	\N	FUSION	INNER_SPHERE	350	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	5ed0f996-b9ec-4d7a-85b8-500ecd5fe6b3		\N	0	0	0	0	0	6	Lama-Deux Firefighting VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb49-7f19-82fd-0f70ff69960f	4834	\N	ICE	INNER_SPHERE	180	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8cc3901f-5635-47cd-98ca-c9aed69d0c9d		\N	0	0	0	0	0	8	SOAR VTOL	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb4c-7cc1-b8eb-864536f75e2a	5095	\N	FUEL_CELL	INNER_SPHERE	120	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	2036d7f6-4fee-4131-a2d9-514af29f11ea		\N	0	0	0	0	0	7	Sky Eye News Helicopter	f	0	INNER_SPHERE	20	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	5072	\N	ICE	INNER_SPHERE	140	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	c48690bb-fa7d-4fed-8cd7-e6e7afa6044d	C1	\N	0	0	0	0	0	8	St. Christopher Cargo Transport	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb52-7363-9406-1098aa6d4964	5116	\N	FUEL_CELL	INNER_SPHERE	200	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	3df04309-8a45-4f7b-bc21-203f30669315	C2	\N	0	0	0	0	0	8	St. Christopher Cargo Transport	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb55-7c2a-8bff-ac2a239a9f9d	5117	\N	FUEL_CELL	INNER_SPHERE	200	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	d922acbf-f025-472b-87ad-5c6730b9125a		\N	0	0	0	0	0	11	Swiftran RTC-215M	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb58-7aaf-9e06-f4553e702d0d	3889	\N	ICE	INNER_SPHERE	275	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	06bb68ce-2d34-4105-9e79-a480753d1f67		\N	0	0	0	0	0	12	Aston-Martin Fiver Roadster	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb5b-7ae1-8f12-cd59cc2cccda	3740	Wheeled	BATTERY	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	35e55516-0bb0-4b34-b165-e398cd009eec		\N	0	0	0	0	0	11	Aston-Martin Fiver Traveler	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb5d-7850-8b3f-6c542e769a19	3741	Wheeled	BATTERY	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ad48a500-4660-4f0c-b33f-ab7897621575		\N	0	0	0	0	0	6	Bailey Armored Car	f	0	INNER_SPHERE	27	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb5f-7f03-9138-cd650b4afc60	3777	Wheeled	FUSION	INNER_SPHERE	162	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	30b78f9e-aded-4369-8e93-c446173979d1		\N	0	0	0	0	0	3	Bombduster	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb64-700a-baa3-813adac7ab4f	3847	Wheeled	FUSION	INNER_SPHERE	150	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5c3bcb98-54eb-4cc2-bcc3-b20bc77fffba		\N	0	0	0	0	0	3	Brunel Dump Truck	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb66-7072-abab-abb8edaeafd2	3866	Wheeled	ICE	INNER_SPHERE	450	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	aa97b5bd-0b13-4a32-9833-e0a6274620f9		\N	0	0	0	0	0	4	Bulldog Medium Truck	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb69-796c-849e-36897a7a2290	4827	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	00393499-2d2c-4d3c-8bf2-3ae7f63aafce		\N	0	0	0	0	0	6	Burro Heavy Support Truck	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb6c-7733-96f6-360657593341	4381	Wheeled	FUSION	INNER_SPHERE	15	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	360c411b-31d9-4382-955a-3dc66e4c8ec0		\N	0	0	0	0	0	3	Burro II Super Heavy Cargo Truck	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb6e-745b-9387-8e136d828309	4382	Wheeled	FUSION	INNER_SPHERE	150	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a85ea936-6db3-49e8-b2c0-31c2c87d70dc	ZZ10000	\N	0	0	0	0	0	10	Ceres-Bikes Flashbang	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb71-7be5-8895-b1a314f2b79b	3933	Wheeled	ICE	INNER_SPHERE	2	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5e199285-52fb-4bf2-95fb-cbaaabbc4e92		\N	0	0	0	0	0	8	Durandel-British 'Blue Nova' Convertible	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb74-74ff-b99b-0639ffdd1412	4104	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	db1c208f-b8e9-48b8-a068-c674be6d2e46		\N	0	0	0	0	0	5	Knox Armored Car	f	0	INNER_SPHERE	12	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	4453	Wheeled	ICE	INNER_SPHERE	60	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	80ac8101-a4f7-4d3e-adfa-68e7879c5766		\N	0	0	0	0	0	3	Lesseps Dump Truck	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb79-7c2d-acd0-aee5587b12c5	4499	Wheeled	BATTERY	INNER_SPHERE	150	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1ced4e6b-d8af-4085-934b-049af5296a07	(Original)	\N	0	0	0	0	0	6	Mao-Heng Charioteer	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb7a-751a-8bb2-1e31e1941b58	4588	Wheeled	ICE	INNER_SPHERE	60	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fb2d3a8d-9adb-4cc2-8ab7-d4b9a6e5d778		\N	0	0	0	0	0	12	Mótuö Chë Shang No.2	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb7d-7a0e-8c54-ca0a6f56b117	4680	Wheeled	ICE	INNER_SPHERE	4	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1ac20461-9875-44d1-91a6-aadac08ab6f2		\N	0	0	0	0	0	4	Pit Bull Medium Truck	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb7e-7909-b38f-56cc78308a5a	4828	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5269c55c-a018-4193-8f16-18682e56298b		\N	0	0	0	0	0	4	Prairie Schooner Land Train	f	0	INNER_SPHERE	90	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-eb81-779a-91c5-b60821553625	7334	Wheeled	FUSION	INNER_SPHERE	360	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	da670b3c-d30c-4714-a313-edd453bcaa11		\N	0	0	0	0	0	0	Prairie Schooner Module	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb84-7391-9229-28fc3cc437ef	7335	Wheeled	NONE	INNER_SPHERE	0	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d2996f51-277a-4a4d-aaa4-d2b56e27d8f2		\N	0	0	0	0	0	13	Saturnus V Grande Circuit Racer	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb87-7c93-89bf-8b7de4a95ca8	4978	Wheeled	ICE	INNER_SPHERE	20	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	adce5e40-b25b-4cf4-ada2-6412e4f00fa3	TLF-LL6500	\N	0	0	0	0	0	6	Saurer-Bucher Fire Engine	f	0	INNER_SPHERE	44	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb89-7bd0-b58b-e50ada6fec4c	4980	Wheeled	ICE	INNER_SPHERE	264	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a97aeff7-1dc1-4cb5-ab28-27cea91228b2		\N	0	0	0	0	0	7	Simca Ambulance	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb8b-70e8-877b-15354dc10ae1	5064	Wheeled	ICE	INNER_SPHERE	18	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a0281282-009e-44ad-a4d3-b123eea8e191		\N	0	0	0	0	0	6	Skoda 'Growler' Service Utility Truck	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb8e-7f30-9caf-e4773869eac1	5066	Wheeled	ICE	INNER_SPHERE	6	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7990126f-1be2-4356-953d-8c4ce3b13249		\N	0	0	0	0	0	11	Coanda Personal Sports Craft	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb90-7b4d-bfac-cb63d60e73fa	3970	WiGE	ICE	INNER_SPHERE	39	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b8d6a34f-5a38-473a-a66b-32e2d8582357	(Cargo)	\N	0	0	0	0	0	5	Cormorant Medium Cargo Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb92-75af-8aec-4c4ff2992fd9	4003	WiGE	ICE	INNER_SPHERE	350	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7f88c3b2-04a4-43d1-b833-eec1545f0a3a		\N	0	0	0	0	0	5	Cormorant Medium Cargo Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb94-7a82-aec4-b489542e4575	4004	WiGE	ICE	INNER_SPHERE	350	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a2e28742-ce58-4689-a54e-f9db5a7da2ed	(Original)	\N	0	0	0	0	0	7	Fulmar Patrol Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb96-7662-a5ed-bfd1a33b7fac	4189	WiGE	ICE	INNER_SPHERE	490	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4b985ebe-c83c-4fbf-856c-a9f9a92dcb93		\N	0	0	0	0	0	7	Fulmar Patrol Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb98-7b10-8427-7d5fff189c62	4190	WiGE	ICE	INNER_SPHERE	490	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	48511ef7-ac1f-4657-b76d-8a504bfa9e27		\N	0	0	0	0	0	5	Koi Heavy Transport	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb9b-7ae6-84c7-e2da71753968	4460	WiGE	FUSION	INNER_SPHERE	500	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9a1bbfcf-1899-459f-8956-9f0144074f82		\N	0	0	0	0	0	12	Quicksilver Personal Sports Craft	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	4889	WiGE	ICE	INNER_SPHERE	54	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9061d697-1014-40df-9b43-b9f76e6b7724		\N	0	0	0	0	0	5	Ryu Heavy Transport	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb9f-7b84-a031-8f75c5f879ea	4956	WiGE	FUSION	INNER_SPHERE	500	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	ea254b9d-512e-40a0-8a7c-14201b2248eb		\N	0	0	0	0	0	15	Lexan Surveillance Helo	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ebc1-78f3-82b4-1446276cb2d3	1868	\N	FUSION	INNER_SPHERE	225	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	843f8179-453a-49b7-b6e0-8039c0f42133		\N	0	0	0	0	0	5	Nishikigoi Support Aircraft	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ebc3-74fb-9232-24f9b1cb39d4	2288	WiGE	FUSION	INNER_SPHERE	500	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9c4d1d7b-35e1-406c-9dc9-a2909bbfd912	Configuration #1	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec04-78a7-99c8-2e2cd5ab7b15	5571	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6c4ab52b-2fc4-41b2-9f77-42583f8b6c42	Configuration #2	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec05-7443-ad84-66d9c73936fa	5572	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7aea721e-2e60-40cd-926c-b17d81295f72	Configuration #3	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec07-7895-a9cc-fee8727e7a9a	5573	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	733bdd44-2a88-4b99-a9d9-0787da609bda	Configuration #4	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec09-7466-9949-cf9e91650d70	5574	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bf7e7bd7-2ef2-42ca-947f-9e445db1855d		\N	0	0	0	0	0	3	Dreadnought Mk II Land Train	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec0a-7340-a6c3-f2700c3efca1	5570	Tracked	FUSION	INNER_SPHERE	500	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fefe041e-5305-40a5-a5b8-7b44c13a25ff	(Hover Primitive)	\N	0	0	0	0	0	7	Armored Personnel Carrier	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec1d-7022-b8e3-21b683ba510f	113	Hover	ICE	INNER_SPHERE	70	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5cac16d3-ad6b-47ee-8a97-378e1f1290b0	(Tracked Primitive)	\N	0	0	0	0	0	3	Armored Personnel Carrier	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec1f-7629-b7f5-095c9748cfbb	118	Tracked	ICE	INNER_SPHERE	30	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	30622169-b0e7-4591-bcfa-5dc2e03a461d	(Wheeled Primitive)	\N	0	0	0	0	0	4	Armored Personnel Carrier	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec20-7319-9741-d48a52da23d2	123	Wheeled	ICE	INNER_SPHERE	40	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	58739ae0-aa66-47ee-accf-2696b342f231	Mk VI	\N	0	0	0	0	0	3	Merkava Heavy Tank	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec23-7b21-9c77-d12e9659c093	2175	Tracked	ICE	INNER_SPHERE	225	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	553aecc3-450b-4efd-b458-96549d449239		\N	0	0	0	0	0	8	Sand Devil Hover Tank	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec24-747e-8eb7-35e3a54106f4	2793	Hover	ICE	INNER_SPHERE	400	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	817599f7-0f31-4d92-9a05-8b9df3a1b0db		\N	0	0	0	0	0	5	Stoat Scout Car	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec25-78fe-9971-587d9dbe9be9	3075	Wheeled	FUSION	INNER_SPHERE	75	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1c932898-efad-4739-bca9-b7b29258105b	(Primitive)	\N	0	0	0	0	0	3	AC/2 Carrier	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec27-7c5f-83b1-dda0d2dad2d4	5588	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	62f5ab62-f2ee-48f9-8802-c97381fffeec	(Primitive)	\N	0	0	0	0	0	3	LRM Carrier	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec2a-7682-bd35-0ff30fe06d81	5589	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bb40c633-00a3-49d0-8960-d1615e95d050		\N	0	0	0	0	0	4	Randolph Support Vehicle	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec2d-7ab0-a75d-5253f2863a4b	5586	Tracked	ICE	INNER_SPHERE	140	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	dc37beec-5998-4535-85a3-ad47cecda463	(Primitive)	\N	0	0	0	0	0	3	SRM Carrier	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec2e-7d66-812c-e49ba2b9acb6	5590	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	480e7556-4756-44d1-8fbb-0ebbd1d2ee41		\N	0	0	0	0	0	7	Strike Falcon Attack VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec30-7a43-8727-98b32f4c02d5	5585	\N	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	17468098-7f6f-4cae-bf2e-5f0ea7e5ea87		\N	0	0	0	0	0	5	Carter Medical Emergency Response Vehicle	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec37-7f5e-b29e-160141dfcb8d	5620	Wheeled	ICE	INNER_SPHERE	125	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	eae223ec-d5a8-4b74-9d6f-7e6655b5e15b	KRV-2	\N	0	0	0	0	0	5	Korvin Tank	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec3a-7dab-a42d-b0c60710239b	1816	Tracked	FUSION	INNER_SPHERE	250	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d302ce79-3f8c-4172-a7e1-b878dea385e5	(Original)	\N	0	0	0	0	0	3	Chi-Ha Infantry Combat Vehicle	f	0	INNER_SPHERE	22	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec3c-7b20-848d-ef876a429829	7188	Tracked	ICE	INNER_SPHERE	66	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	91f176b1-3218-4ac1-bc7d-3c3d6c479759		\N	0	0	0	0	0	4	Chi-Ha Infantry Combat Vehicle	f	0	INNER_SPHERE	22	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec3f-7a7c-9852-18a6a3ce05a4	7187	Tracked	ICE	INNER_SPHERE	88	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	02b3bd11-8ea8-4bba-aa3a-edd6d8594888	(Fusion)	\N	0	0	0	0	0	10	Cobra VTOL Transport	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec42-78fe-8163-1c465907ceb6	7190	\N	FUSION	INNER_SPHERE	300	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	dabbee86-e476-4147-8180-641bf8439d18		\N	0	0	0	0	0	8	Cobra VTOL Transport	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec43-77c3-9837-427bd3b5f580	7189	\N	ICE	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bf551c46-aa7c-4035-adad-f32743d02b6b		\N	0	0	0	0	0	4	Sturmblitz Assault Gun	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec46-70f9-b001-8c48763f9513	7191	Tracked	ICE	INNER_SPHERE	300	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	794c834c-d99f-41c9-8916-ea239b8aa447		\N	0	0	0	0	0	3	Apostle Self-Propelled Artillery	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec48-7c24-9448-12f9f7a3db2e	7414	Tracked	ICE	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c81be855-c7d3-4461-a49a-4475b4f9fa1c		\N	0	0	0	0	0	8	Asher Hover Scout	f	0	INNER_SPHERE	45	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec4d-798f-84ad-eecdcc54759d	7410	Hover	ICE	INNER_SPHERE	360	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d5ca8f84-4859-4ad1-bb3d-db977566473f		\N	0	0	0	0	0	5	Dunning Mobile Tactical Command Post	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec4f-7522-895b-66f3e0e40f6e	7409	Wheeled	ICE	INNER_SPHERE	150	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	75095c97-90c9-4cda-9c43-d7aaca3d2051		\N	0	0	0	0	0	3	RR-3 Recovery Vehicle	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec51-731c-94b5-a5c494fdd6d1	7411	Wheeled	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4e18cb08-5941-4ded-a64e-a8050b50d832		\N	0	0	0	0	0	3	Reaper Self-Propelled Artillery	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec53-79c4-be1e-77db6ca4932f	7413	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	703a9e4a-c306-43c2-91a1-97db24dfeba5		\N	0	0	0	0	0	4	UTR-588 Recovery Vehicle	f	0	INNER_SPHERE	90	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec54-7008-ba53-94c900e2263f	7412	Tracked	FUSION	INNER_SPHERE	360	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fb9005bb-3305-4eff-89b0-541388ae774d		\N	0	0	0	0	0	7	Barouche Military Transport	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec6e-7bb0-8a34-4b08f83b9763	3793	Hover	FUSION	INNER_SPHERE	500	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6b4696b5-7ecd-4f9b-9f67-b1c11fc65e33	HW1	\N	0	0	0	0	0	3	Hwacha Urban Combat Vehicle	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec70-76c7-a26a-3b560de8e435	4350	Wheeled	FUEL_CELL	INNER_SPHERE	150	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	ecfc2be0-2223-44c9-9bec-3157c10caf24	(Rescue)	\N	0	0	0	0	0	11	Humming Bird VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec72-79eb-ad16-cee49f243461	4336	\N	FUEL_CELL	INNER_SPHERE	330	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6fee470f-876d-424f-a572-92a71e309fdb		\N	0	0	0	0	0	3	White Tip Submarine	f	0	INNER_SPHERE	250	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec75-7cd8-8032-f2d83d9a0544	5406	Submarine	FUSION	INNER_SPHERE	500	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	94c8892d-1c71-451a-b66e-585daba882f4	BFFL Drone Bomb	\N	0	0	0	0	0	5	Buffalo	f	0	INNER_SPHERE	100	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec7c-7f1d-b79a-8290b0bb8b37	5777	Hover	FUEL_CELL	INNER_SPHERE	500	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d398c89e-cc78-4fdb-8884-550cdcff5b0e	(Fuel Tanker)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	01a0bb4b-3acf-740c-a575-80954010f2a7	5050	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	543ca099-6d14-45a5-a4a0-0d06fa961a6c	(Mobile Headquarters)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	01a0bb4c-6e83-721d-992c-a9dc9c849827	5050	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
\.

INSERT INTO unit
SELECT v.* FROM v3_22_unit v
WHERE NOT EXISTS (SELECT 1 FROM unit u WHERE u.megamek_uuid = v.megamek_uuid);

-- 3. only on the units added above (a unit already stored has its own items)
COPY v3_22_item (megamek_uuid, id, location, omni_pod, rear_facing, tonnage, turret_equipped, name, tech, fire_control, jump_boost, drones, mash_theaters) FROM stdin;
019f583e-e29c-762f-9274-753bb6064e76	d178ea1f-85f3-4783-b336-27a29546278f	BODY	f	f	0.015	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	85080b3d-e629-4ff8-9315-a79e1f67e195	BODY	f	f	0	f	drone(remote)operatingsystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	7b8f5ad5-87a8-4ece-b080-4f70c6cbfc0c	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	913534ee-a56c-488f-a224-b56e098cabb6	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	c6b8b46a-ba7b-46a6-82d2-19e880555ae8	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	f11ff9c4-c8d8-4baa-b54a-55c9fae2bdef	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	74f78292-28e8-4b68-acf0-f9dd7cc1ecb2	BODY	f	f	0	f	drone(remote)operatingsystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	04ea481b-c279-4305-9629-080163c0f30d	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	0d4f72cd-1cf1-4698-aa49-95c13ca77c15	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	bc2c0fca-ca3c-4baf-989a-67dcf0e089c4	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	84d28119-d160-43ab-b128-c58e90beeb15	BODY	f	f	3.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	68980e23-96f2-403c-8836-6394fea81530	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	d3b954a6-022f-4653-9cfb-993008a16053	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	4f060556-e32c-492c-b4e8-ec9fd98c34d9	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	449064cb-3e34-448c-9f24-229edf769987	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	489c2ab3-bf2a-4a00-a2d7-ad1b7967ffe6	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	eae51b7a-5e97-4495-935a-633f32549f6a	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	a5186b43-0647-4751-89e2-a6f7bd0caa78	REAR	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	aa34e634-a543-4dfa-9f8b-3f299a7e380b	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	73d38300-1eb6-4a2e-af86-60f48581bf35	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	4c9352ef-6844-4ad2-9580-c466dfacc3eb	REAR	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	4ed9e3da-785f-42cd-a6ea-b641ec58c23a	BODY	f	f	2.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	32b2b9e1-4976-462c-a40b-5b00accd0e9b	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	4784df3d-3640-45c3-be17-204c07a4cf2d	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	f49fc0c5-afe6-4d34-baab-154690b8a744	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	0252718b-cad0-4b11-9ad3-1b5c8e387b5f	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	3e137951-b1d9-4e35-a8a0-192338661990	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	83fc2fd0-ee8a-4caf-826b-019bfa439b00	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	a6c8cc03-c96d-420f-a5ef-5794ee423f5b	FRONT	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	54979486-2bb0-4eda-9cc3-dc97bba4f6ab	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	6cf5c095-0198-47c4-804a-1750215b8bcb	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	163a8a37-ca4f-4b5a-9bc0-a48b7a92eac1	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	f881204e-1c93-45ae-a74e-afea0dc932a6	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	7f16c3ee-0020-46b1-86b9-ad7f5d74adcb	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	c05a25ee-bc0a-488c-b047-e7fe9b81bdf6	BODY	f	f	2.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	2afe76f6-fa9b-4924-9e64-2330721ad678	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	d5fb954a-013d-4d94-8b10-d78b0d095ca0	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	b7c048f6-44b0-445d-a999-446c384a10cb	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	b16748b2-e82f-4a2e-b52f-f98f3561e5b0	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	f5630a95-343f-44ac-8920-a75c5b4dc900	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	3740e0ac-4909-4b6b-85ad-41fc9a83b4f9	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	da8229f8-f91a-444a-badf-cc06a91f69b6	REAR	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	88da7c59-ac59-4f7f-a4ec-02e4e6bda3ce	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	004251a2-c124-4299-9786-bda5f864d797	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	8e6aa964-7723-42fa-b4ea-9718dfd2e72e	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	c6e7361c-4fb6-4f5c-a4fd-b050f017515b	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	c1fb83ec-f953-4d27-a9b0-b61fd67b925f	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	ee1f286a-8b14-408d-9f70-826e58819ee9	BODY	f	f	4	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	5ded6068-8c15-4a01-86ed-33226e319f12	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	e3f18f3c-884a-448d-b324-c62d40599dd2	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	5f74fa64-3bf9-43ee-83d4-503b386fc353	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	c383d498-c5c4-43cc-975a-9b8b25f95127	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	3e128ee4-30e6-40ad-b46d-6b73b2a1f977	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	dd9426e7-0d10-4654-b2b4-cd6652187a68	REAR	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	0c3e8915-57f5-44f7-984e-5b69cfc4c734	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	0171201b-4019-4831-ac8a-569b506f7e8f	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	3c41ff85-bc6d-44df-8464-1cc3d1626b99	BODY	f	f	4	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	61aa6e3b-ba74-4e85-9702-ac0d5c6164e5	BODY	f	f	45.5	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	6051985b-4fb2-4a96-b680-9c6fbd2f9c9e	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	230eac13-3a8c-4b26-95ac-748902462e4a	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	c74b39c3-4ee9-4603-9613-212dd7ba8d87	BODY	f	f	0	f	svchassismod[dunebuggy]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	f8434547-35c1-4dcd-b023-90b94d7eb1c2	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	40f3f989-7e2d-43a5-8b38-8be79b1a1daa	BODY	f	f	5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	5820aed1-77ab-4923-b26a-c6e9554c6deb	BODY	f	f	18	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	7f2205f0-92cd-4b54-a604-716b06d0df91	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	11
019f583e-e654-7265-b77a-515a1e7450b2	5f379a57-b89a-4615-a81f-ee32abcc5d99	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	c9056f9f-bc4c-4e45-b110-a32ba0304225	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	e09613d6-2d6b-438c-b0b9-c63b19c1c69f	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	58d88bf8-64ea-4d8f-9479-4edb887e06dd	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	b9ec4418-fa4c-4fdc-b202-db322a30ff76	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	9a8f2937-3573-4129-be42-05c2b7a2b309	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	178915da-eeeb-4db2-8c22-fc5eaf820cd3	LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	124747c4-ea24-45c7-b5c3-8f6df7714d54	RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	a32261c0-2c70-4214-ba23-4d4f84591610	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	e7046a12-c4bd-482a-8c96-72e98dd1dd38	REAR	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	7d869fa0-bb5c-4739-9841-6751b0d8ff18	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	bef889ae-4ad8-498a-93f3-68a443858e22	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	eb068bd2-0a32-4cb8-a12d-d5e2e4c635d7	BODY	f	f	22.91	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	7c46d0b0-3ebd-4b0c-9b0c-54112c526783	FRONT_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	febec2af-d961-438b-b00b-9cf89b48a55f	FRONT_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	8ca1ee80-94c3-4ead-a6d6-ba76f96535be	REAR_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	09595484-64ae-4683-b542-ef22b6c701c1	REAR_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	95e05b74-d8ec-4636-989a-646eae5fd7f8	FRONT	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	b5396ab5-3c18-4008-a474-5e453f4ff2f0	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	0fa2e584-cd36-468e-aa87-5871bf3983f1	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	fb6e07e6-3762-401c-81b0-d21194ae6209	FRONT_LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	7cc6ae0d-822f-410b-9614-81ba29173f40	FRONT_RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	e9b25be2-a240-417d-9109-28b8717a7e1e	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	4afd0e02-ca67-43cf-b91f-815343f5590b	REAR_LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	9bcb189f-3b11-4bab-8ae0-71232a256216	REAR_RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	2780992b-9356-4cb6-af8d-c2970ca8ff65	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	7878e2ca-143f-4f1a-9ec1-728efb2b83a3	REAR	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	a17aa9ca-a0a6-43d7-bcce-e60bf60bf019	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	89712fd0-9320-4421-b204-a6f1e901c01b	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	a8ea8c33-15f4-40e2-a39f-ca9ea09e0802	BODY	f	f	5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	2a759beb-7111-4b12-9001-32b1c34b88ff	BODY	f	f	18	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	196b5648-5dad-4460-86cd-a756e631c408	FRONT_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	ce8560a4-06b2-4fa4-bf66-8db8e993784c	FRONT_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	94999871-14f0-46be-9e1f-a64094536147	REAR_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	0585ac58-864d-4f3f-acfa-9142d9f84787	REAR_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	8fe50f74-fafd-4814-b52e-e20100c5ce73	FRONT	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	50d65627-0952-4b72-ab6f-d2ae29b0e481	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	320a6a6a-3ee6-4230-93f9-e7a74f29d757	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	446cc57e-c90b-4543-b182-e580fc2b6efd	FRONT_LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	64fc94b5-a477-4215-a6f0-06b7b9c2b58e	FRONT_RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	f2918fb7-354d-47c0-b1f4-0155b8feab92	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	719e5899-4184-46f6-9de2-459799968ebd	REAR_LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	e5c5afc8-1b48-4444-851a-42c8eb248b56	REAR_RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	f785124d-09dc-4fbd-ac7e-bb8371c2899d	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	3de78137-1093-44e3-8127-22181ddb640f	REAR	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	554dce94-08b1-4363-892f-4e27a3d47def	BODY	f	f	100	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	dfed235d-c939-4d47-9b69-664dbdb08f2d	FRONT_LEFT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	115202d2-475a-4c30-866b-3d26f3b7411a	FRONT_RIGHT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	a7fbe98c-c26f-46f8-a95c-64e2a0849e83	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	8cebbd3a-2f4b-49f9-a672-a2f89100032c	FRONT_LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	3bdc0775-ea66-4c47-b606-50464b56d095	FRONT_RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	ac7ca035-e718-4c34-815b-75083b622e34	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	ca2e4eb6-81a7-40e0-a830-decfdee9b94b	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	097246b1-039c-4b25-bb9c-38300f760878	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	942599be-53a5-4d7c-918d-a5f538834f74	BODY	f	f	16.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	1bcf8305-020c-4e30-9fbb-897ebd83e048	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	4df88c60-111b-4b3e-9940-a013ff48f759	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	c2cf3099-efb0-473f-8b1d-41a49ccb992e	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	01466f9c-ce36-4e8a-bcd4-199247c848b2	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	58262435-6a25-4240-a7b9-b79900ce310f	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	14fdf68e-f7e6-4fd3-8490-aac367b72db8	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	c6b4e64d-974c-486d-bcbe-fe0617dbddde	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	a963d482-772e-4000-8b2e-493412ec9393	BODY	f	f	19.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	720bb2ef-7a1f-480b-8165-3d107641cf43	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	a7e8ff77-b268-4d7e-b3cc-3ba12b4487cf	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	935ee0e4-315f-44fb-9c04-9641aa4d8079	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	99d43bf5-f5ea-4e1d-afcf-4c85ff572868	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	fec7a575-9cb3-49f8-8257-17f05308435b	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	401bff10-77c8-4ff1-861c-00636a5c0bee	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	f78995a6-cd10-4c83-a8ea-da7b73bb2df9	BODY	f	f	13	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	12db6891-6d10-49ad-aa6b-247bfafd9548	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	4ec11c5c-b8f7-490b-b3ba-24aedfdd7ffb	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	51c70c9b-bc00-4a31-a0c7-00e2abded20e	FRONT	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	60c99eee-1256-478a-94e7-9090d58cffc3	FRONT	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	38583931-7be5-444f-b0af-de51de924137	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	3ed7948a-b2c1-46ac-a21f-6671f59934cc	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	88e52def-3964-4b6f-83b1-329173c9e54a	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	11308b73-7e05-4641-b358-69d5542fafc8	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	184239eb-01bb-4ec7-a2a3-d6a4b5c946ae	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	56094ea7-2b40-4606-ac49-c7dc06cf5662	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	6571fc21-1a5b-4f7f-9076-f90e791f9159	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	86c647fe-ee38-4a78-837e-043138d048fd	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	88f54394-eabe-4c52-accd-f0b3c905ef2d	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	b44bbf43-ffc9-4baf-82cf-4293dc0e67b2	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	ef814339-026b-433b-894a-69ea8e706e33	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	39c2a6d6-f0ed-4737-9768-bc0f9ee96f55	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	5e6d6548-f419-4241-9c33-b8f0d1d71ccb	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	6b49631d-8ee9-483c-ad46-f5dfcd7447ba	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	9230ab6c-d6bb-4553-85a4-6696663dcffe	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	ba41032a-0ff6-4246-aeaf-c9c2453b983b	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	2717a717-3df6-487e-8714-131c6d4bc362	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	327b056d-54d6-4d36-89d9-66fc438dae26	BODY	f	f	19.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	8bba4d6d-4106-46a8-808e-1f2ca7abc758	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	f4769bc6-a3a2-4c35-9246-e2a3a8259169	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	4727afc9-d1a6-439f-84ea-c76b9365bc73	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	d0e8357f-3e3b-459d-92cd-42bbe3597661	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	5f52aebc-d67f-483e-8b09-ca1f077fe31d	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	16203733-b3a3-4f8e-9149-e4a04dbd893f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	93ea314d-f8e5-497b-9a5f-bb421d2d7dc2	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	4ebca2eb-326f-4279-be46-8baee5f0d8a7	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	37b67493-46cf-4459-9303-abcddbaa0b23	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	f2ee4dac-b204-4bb7-9838-d49dc75ddea1	FRONTTURRET	f	f	0	f	lrm10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	ece19c52-ae34-47a8-943b-ca02dce87d8a	BODY	f	f	0	f	lrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	2949fd62-91ea-45a1-a3cd-77f2101580ba	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	b9722dc4-fc31-4cb3-a872-861fbcc54e8a	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	6df4daad-0268-4788-87ba-3795d94655f3	FRONTTURRET	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	1f67811b-3975-483d-b8ee-a6662e8cf25c	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	04e4423b-1a0c-488c-b3b9-f33c5d7e8540	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	a7701fc6-13a8-4136-87e4-c53bb01a8288	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	476b43ff-67c9-45ab-93ff-9e06fdbb98bb	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	e0cc8638-513a-4f25-98dd-8e20da0c2886	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	158a3f1f-f56b-412a-9852-7c0dc11d0b12	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	77052b23-3b7c-4518-9ee4-0d27b350bab7	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	d71a3fc1-d220-498d-94c2-82091aac2daa	BODY	f	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	3ee499cf-542f-4dbf-914a-67f72b81335f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	db5a3337-0405-4911-b0ca-fe33cf93f287	BODY	f	f	15	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	25cb3d9a-8006-41e8-8158-28e0507ca5dd	BODY	f	f	5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	38a13f4b-c78b-4a99-8185-843e333e3d58	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	8bb44247-daed-42b2-a623-6e7920bf6ac8	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	57632d13-eafa-4345-95f7-4d0f18a60327	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	8457e38b-f698-4cb8-9a03-f21f9c0549b6	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	fcce5a60-1b8f-4e1f-9f91-2027e3a28e3c	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	bf825dd3-a7b7-4109-b4cc-225f9e139d09	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	9d3d6bc0-9e15-46e7-829d-3f009d4418ab	LEFT	f	f	0	f	bridgelayer(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	ea6f2dab-47da-4463-95c6-8efd792325d0	RIGHT	f	f	0	f	bridgelayer(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	0e4ac332-2c53-4d8c-8be1-9b070a105fb6	BODY	f	f	5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	0b859600-a7d0-4f95-b900-6f74ae9fd195	BODY	f	f	5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	9400331f-5959-4485-a027-16e7b636a4a1	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	0e89fe70-7926-4a15-831c-c7cc66b993b2	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	28352f84-2695-48fd-b589-8e4cd0b199f4	FRONT	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	4dfb7cd6-dd04-481e-9cdb-35a0a7016077	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	1e9a7ee3-cac2-4d2e-ad77-449c435efbbb	BODY	f	f	19.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	30be9999-43bb-4b7b-87be-87f39114f7b5	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	4f24e2a8-657b-4384-91d8-e8a8f57e8d29	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	a7227e85-7507-4267-8452-142fbd06a5ed	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	fe90bc48-6956-42d9-b8b5-87a8c5462b39	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	9c9a20e3-8e6a-4a22-b3b4-74195337f483	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	28cd051d-35b5-4b77-afb1-2196df8d3eaa	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	50118fcc-cac0-47d0-8613-673c74ad38f9	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	e1d7c040-ae04-41da-b767-b112f4cf8ab8	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	c1ed9c32-940e-4cfc-90e3-a6b83b14e2ba	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	2ee4a2c5-783f-44fa-bd17-d955b427a895	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	e321ad42-c2c8-498c-9042-68f6ec98f7c4	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	e06c25a6-ba43-49f5-8e79-f804977ec248	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	311a522a-5d02-4188-80ed-834ad2cfa5f6	BODY	f	f	1	f	cargo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	8e129420-9f21-410c-bed6-a38c287213ff	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	f23b9c5f-de8f-4f50-917f-8eec0d978692	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	5a570f08-d082-4b29-8723-501bdc6fe3b6	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	21dfb327-ad75-4c76-9664-2a73e841d148	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	4b7d58eb-2905-4c67-9f78-4237e6ade167	BODY	f	f	21	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	cb9659d4-8f55-4f84-b758-1c9e030e6561	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	5470d3c9-c61c-402f-ad5f-3bc6e9411187	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	bba14e83-ca71-46fe-89a6-3ed54613686a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	f2408ce8-6f91-4dc0-8433-cce3d61413c3	BODY	f	f	17	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	5d2f0bce-e220-427c-98c4-41f5da7dc9f1	FRONTTURRET	f	f	0	f	ersmalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	0126dfa8-fb79-4f85-8c5d-860f073e75f3	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	16cc83cc-5d78-4034-a514-cf1a5b76af68	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	3d0f6917-232b-4e55-9850-64968f575362	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	ee95753f-3aa6-4ed4-b815-7265c14f3526	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	93daf1e8-0f77-4d84-85e0-77b18cefbf29	BODY	f	f	12	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	1515e7a2-99f4-408a-867f-459a2065bdf7	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	535fcc3e-bfc3-49ed-91b7-14020a4184e8	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	59637d13-6717-481b-aca6-34e9a6691671	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	a6013f32-7b19-41ee-a6a0-8d96f56c1cfb	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	2fd573f9-52ef-417d-a20e-6c40c9fbbefc	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	daf91a6e-75ee-4137-9e4d-b8c3012920c6	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	79001347-8a03-42c7-9af3-9a2b49f21a1e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	5656c614-002b-4075-915f-a3a51589ae2a	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	3522f860-b1cc-4e7b-9c1b-87164fc8c834	BODY	f	f	16	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	3a5cd110-43c2-4d23-863e-5a106b0eb1f7	FRONT	f	f	0	f	srm2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	79698968-9e58-4eeb-baba-eedbea519fcb	FRONT	f	f	0	f	srm2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	026f16e9-6164-4338-979a-7f58e3d77ae2	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	d34c7de6-be72-472b-bbf6-0924b7eb0a02	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	eea5fc4e-a5ff-4712-b990-553b989d4b2a	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e731-7888-8c39-b99da4acf787	127a5888-257d-4757-a30f-6b5b097b6734	BODY	f	f	36	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e806-7a90-a05e-960ee185f5a1	6a4c778d-600b-4e5f-87c5-83141923391f	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e806-7a90-a05e-960ee185f5a1	e7f81732-caaf-4da5-8fd6-6536ddd67b9b	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	6999aa19-c928-4f67-863a-3e266fdd151a	BODY	f	f	3.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	5e2f562d-68f6-46a0-bb68-7f27c2219ffe	BODY	f	f	0	f	case	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	5aafa339-6d8a-4c34-9b26-8dad8e80fb45	BODY	f	f	3	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	bf279cbe-4feb-4719-8581-03395170e6bf	BODY	f	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	e14e0068-09c2-4eb8-a971-09a1acfe9931	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	e2ab9095-1da5-49f7-a9c0-b7d2a1bb7462	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	828b85bb-282c-440f-8ae3-ee45fd6a06a1	BODY	f	f	0	f	advancedfirecontrol	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	cdf846df-c7c7-44b8-ba9a-da5b3f3d2b86	BODY	f	f	0.075	f	standardseating	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	2a958a76-485a-41ce-985d-4cd796fb5448	FRONT	t	f	0	f	supportlaser(semi-portable)	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	7ce14156-5ea9-4789-8e29-ea90cb7a3e08	BODY	f	f	0	f	svchassismod[bicycle]	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	52243389-2c92-44b6-af37-2d880c4b506b	BODY	f	f	0	f	svchassismod[omni]	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	3770c05f-062a-4dcb-9a91-87a9106478c5	BODY	f	f	0	f	advancedfirecontrol	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	b12b784a-04f9-4628-aa31-818316d7c33d	FRONT	t	f	0	f	autocannon(bearhuntersuperheavy)	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	e5f223c0-6491-4f12-8155-4c8cbf104260	BODY	f	f	0.075	f	standardseating	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	951225d1-a995-48ea-811f-d64c6d9d5679	BODY	f	f	0	f	svchassismod[bicycle]	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	be9163b6-550c-49b7-a6a1-f9e45048f96e	BODY	f	f	0	f	svchassismod[omni]	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	9531ac4b-71a4-4437-8073-484b8b1772d7	BODY	f	f	0	f	advancedfirecontrol	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	45089f52-24ed-400f-9f06-c1a8b326952a	FRONT	t	f	0	f	laserrifle(mauseriicias)	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	6d106aec-d267-4ba3-9fee-da0f90cb84a1	FRONT	t	f	0	f	laserrifle(mauseriicias)	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	5300517d-854c-4d93-9b2e-ff911b3496a8	BODY	f	f	0.075	f	standardseating	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	3b470858-1750-4c73-8939-5ce7bb8dbec2	BODY	f	f	0	f	svchassismod[bicycle]	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	364cd2b5-3945-4caa-a677-d825866bcf5c	BODY	f	f	0	f	svchassismod[omni]	CLAN	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	3df341ad-d52d-4ce7-bb00-936e10ec4530	BODY	f	f	0.05	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	1f445eab-492f-45ea-96e9-6735518e3f9a	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	a9bffc95-8366-43dd-b890-46f371651272	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	2cc6d792-a8f2-473b-912a-4122c8d3ca73	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	dc4a3f80-c6eb-4e1c-96dc-d62dcea71ff2	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cf-7c27-b0c7-b3c22c44e45a	7e67bc5e-9988-4b76-b205-c6d4a69290b5	BODY	f	f	0.04	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cf-7c27-b0c7-b3c22c44e45a	e164a262-7e7c-4ca9-aa12-5984f7397310	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cf-7c27-b0c7-b3c22c44e45a	2ba6b63d-bccf-4e1c-8adf-88dfcba3e073	BODY	f	f	0	f	svchassismod[monocycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	4106ebff-055b-46e6-9279-b54f522b80de	BODY	f	f	0.02	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	1269cf43-8c34-4af2-88be-7225aadfbee1	BODY	f	f	0.05	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	37f4ab56-f856-4b74-8e1f-5670bcfa0e08	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	410eb048-bddf-4c1d-bbea-812b93b7cca6	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	7a5fdf32-0547-49e8-933b-dcd5f48ae82b	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	9630f631-9d61-486a-94bc-c22eea7bef27	BODY	f	f	0.2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	e90a87cc-6347-4f39-b37b-7a7a42c43bb1	BODY	f	f	0.1	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	390da6f9-e62c-4745-9c0f-a6e24dc0ce27	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	c74bcd9d-d0f7-4a3a-b446-d24eb9d28acd	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	1d69a440-8740-4ff4-b00b-e3847212d9f3	FRONT	f	f	0	f	srmlauncher(std,two-shot)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	a7ed2c94-ff16-4c9d-9dde-b075c6b9c0c8	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	0d098d9d-85d5-4bf8-afb2-d340cca0227b	FRONT	f	f	0	f	supportlaser(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	ee11ad20-251b-4efc-a1fd-4c09282d3b1d	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d4-7f7c-9235-fa32872c784e	318eb02f-6afc-44df-9d7f-e81f6c3bd360	BODY	f	f	0.7	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d4-7f7c-9235-fa32872c784e	30df359f-2850-43e5-aa2c-2111a11d1f6a	BODY	f	f	0.525	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d4-7f7c-9235-fa32872c784e	ad4f64f4-d6ff-43b0-81e6-8930cd62630f	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d6-7df9-8874-e3dab445ead1	a387ab3c-7564-4bd7-8332-433da38634ec	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d6-7df9-8874-e3dab445ead1	906dce29-6cc3-4fb9-891e-86eb8868f2ce	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	00b2926d-3a4b-4dce-bf03-a903c9ee04eb	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	8238c6ca-1896-45cb-bb8b-39be434ba123	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	5bbfcd53-0381-43b3-b22a-82cc087f0393	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	73aea7ac-504c-4a59-93f3-1594994c709b	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	a82dd00c-f9f4-4831-ba3c-1c0e3b94c7e1	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	6297c329-a727-49e6-b7dd-763812d226a0	FRONT	f	f	0	f	tag(light,man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	2c687db6-1c16-4cf1-8c38-9c24059112bc	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	bea3dfea-b714-414e-965a-476e29f3d334	BODY	f	f	0.25	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	3ac68db4-ebfe-4b1d-b87f-d29478a92bd8	FRONT	f	f	0	f	grenadelauncher(auto)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	dccc4782-546c-4838-92b8-04c29d488e1c	FRONTTURRET	f	f	0	f	heavyflamer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	db00a199-0e7d-47e5-aec8-7d35531d221f	BODY	f	f	2	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	ea9960ab-05b6-47ef-97c5-f76f7d425633	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	24a28421-8428-4885-9626-87a035ca1820	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	8d8dfe9a-0cad-4ce8-a69e-ce9e6a2aed99	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	00212d73-584e-459b-a22c-c989fc2a966a	BODY	f	f	0.04	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	b1599173-f08e-4ba0-8435-76086240df7a	FRONT	f	f	0	f	srmlauncher(std,two-shot)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	721bee93-7364-485f-8026-0552092251a6	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	207ca81d-f7dc-4910-a5c6-0144ad452818	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	804e0396-3810-477c-a0ae-7f543736bf42	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	c0900e77-907b-4da8-9eed-817f5d0bb309	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	c9d796b4-67b2-40eb-a719-7a18649f7633	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	65635ddf-f0d3-4421-937f-3eeec31bf856	BODY	f	f	0.2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	e9de501f-490b-49b5-95c2-e7312b25a0f4	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	37c9c085-3d5d-4938-905f-4fa3d6ce1c3f	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	377f715c-b254-455e-9ad4-9aacc9a09ee2	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	7b85c9bb-a33b-4d40-a81d-722fdb3c257e	FRONT	f	f	0	f	wire-guidedmissilelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	8d2e413c-2f75-4586-993a-606905d7ea90	BODY	f	f	0.3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	71cbbf71-92cb-4d19-b0ec-9c9c9045e6b6	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	ca12e49f-fc17-4712-93e1-0d875e0faa77	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	fe6905c0-a844-4401-95b4-661d98fcacfe	REAR	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	32e9c7b4-de6f-488b-bd78-79665009bfaf	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	1cd061a9-30b1-4e4d-8089-2569ebc794ee	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	9ea81b9d-931c-41d0-a418-bcd4ce6664b1	BODY	f	f	0.7	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	61e9fa3d-6e69-4028-9176-2215596315d7	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	2bff91e9-e63f-4f65-af59-8ceb102faf21	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	5a01624d-c61a-42d4-95fd-add96e55c037	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	7ffa021e-2642-4045-8bee-f98bbf005c43	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	9d138e2b-c94d-4ee4-988a-fbadbaa4a23f	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	2cb3bae2-2567-4006-a142-ba7eaf02e0b1	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	f2692c99-c769-4bf8-ace6-8e7a77e23a53	FRONT	f	f	0	f	activeprobe(beagle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	8f28348c-2dd4-43fe-8ed6-af59b132f85d	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	f1fcffe8-97fd-47b9-829f-a324e5290741	BODY	f	f	0	f	armoredmotivesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	8ce6fd30-559d-4cf7-a2dd-fc0b02b00133	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	0365fb84-60da-41cc-8580-b0b16d2fd57f	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	27e78816-2aea-4424-9c4a-70e79773befa	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	2bb96172-eff9-489e-ad7a-f21067933895	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	936440ae-6acb-4601-a0f9-9048cb89894a	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	ea29549d-d184-4eea-93c5-8c57115324ee	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	5d3e482a-51fa-437f-bc58-553c7e4f54b6	FRONT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	8f2107d7-8a37-4d2d-9d77-850fa4fd7111	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	ef13d8aa-1d51-436c-99eb-80643ca1481d	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	0dc53a06-a0a6-4fae-8268-cc9674d40065	FRONT	f	f	0	f	miningdrill	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	ec3331d2-bfd8-4082-89cc-f2a3d3c40254	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	af294e58-2ce0-4a69-b23c-b4e0da56b980	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	170ff5d9-25ba-41a3-a8cd-65220aa83604	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	b02fa157-d635-47bd-947c-6e532828d82b	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	61bb938a-adf2-401c-b0a6-7281df00a312	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	b6766564-8458-4102-ae33-420434e2833d	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	e4dfa7e2-9f2f-45d3-ad93-ba685689fde3	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	f2b87252-a593-40b5-891a-7a8762c7a13d	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	c283a94b-973b-4a90-857f-72aa82933e7a	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	201a5be6-dd8c-4035-9d88-baaa1f17ddb5	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	aa41e0cf-1492-4232-89cb-03c9ff18080b	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	76ac2946-aaf8-4a17-8b51-bcda98cebc05	LEFT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	31bad12e-1430-4bb7-b134-9d34ef153520	RIGHT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	62ac3afc-5a59-4be2-87e6-b6fee95b8b6b	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	0460d82f-8885-4192-a4f4-38f5b17ce2a3	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	09d7db7a-31d6-4125-84fe-9a7158eddb0c	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	57fc4b85-5079-4104-a417-62b4d47d1995	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	72454eeb-9003-4c40-93ee-66a505bf8be0	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	8439274a-d85f-49db-a2d9-bc7a6c322fcd	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	91cfb536-e9f7-49ac-b53b-9474f90d9dd8	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	bc700097-6868-479d-a003-e40bc5c5b7f3	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	852ce2af-293e-43c8-983b-6fe4ee7ef8e5	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	cdf3b480-e446-4bf5-b5ed-59d711a63f0b	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	cba0c16d-8111-47a0-8f1f-d30d519d6c13	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	c2d44efc-d565-4c83-84e1-815fefed6ee6	FRONTTURRET	f	f	0	f	rifle(cannon,heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	0edf2d2c-d336-4026-ab5c-e8f1444ea1d7	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	ebc17890-2c5d-4623-8db3-4effa27959d3	LEFT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	43db92cf-42ea-455a-a63b-ce22ab49bba9	RIGHT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	62abf73e-dc1f-4c82-8ea6-c1fb7af6071c	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	ac939da9-48b0-4045-9085-ff86a80ab663	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	77984b5b-d7a4-4dbe-8111-2f66ff59fa27	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	77b6da7d-0fe7-46a7-8992-98c5c39e085d	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	3b2a8eb1-5cee-4fc5-bf94-e33bd1a0b013	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	9f14a36c-d71f-494f-bb9c-4088b922b6fb	FRONT	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	46498201-d62c-49b8-9619-2d3483b8464a	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	c542748b-21b8-4566-bb69-3dc482861948	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	fe4c6d7c-35a9-4d82-9ef9-e2856793f5fc	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	2e4bdce0-4d21-4eb3-a9db-173c4fb5bfa0	BODY	f	f	0.501	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	6d6e151e-224b-4917-bd83-d989dcda937f	FRONT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	bb178bfd-0a3b-4124-af4a-199d81ed7cc5	BODY	f	f	0.525	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	8afe7a65-238a-4a46-ab6f-ea9df32b4993	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	47a228a5-d680-46c8-b7c8-b86f1ba8ed2a	BODY	t	f	3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	e308de7b-cd15-4f05-ad0b-b7a89bad1ca5	BODY	t	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	a105ba83-8f27-468c-906e-ee56463bf1b2	REAR	t	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	a6cbc27a-0d6f-4837-b45f-cd59e9882d9f	REAR	t	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	f6f459d8-d217-4b6c-bd2c-f270b810db29	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	cda85549-b5db-44f1-bfd7-3fd54043e897	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	20d8fb98-44f6-4785-bd22-041ad448320a	BODY	t	f	3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	0405a4c9-0ea6-447f-a95e-a303d037eb58	BODY	t	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	fc8bc309-84a1-4669-aeb5-d50c47ed6873	BODY	t	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	5bd76080-2dd2-4e09-bf46-a5535decd282	BODY	t	f	1.7	f	refrigeratedcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	8ecbb556-b602-4e00-9739-016e3c9e430b	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	40a24979-6509-4655-8783-99af28dcb5f2	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	bca8b6a7-fac4-4364-9bab-a54f5e1a7a9f	BODY	t	f	2.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	53582143-2eda-43c7-bc27-ae14054b515a	BODY	t	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	6
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	d224d1ba-d9db-477d-b928-237c81b622da	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	32f48b80-6e07-41f4-b116-0ae13af0bd09	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	1d61c1c3-3ed9-4a9b-a4ec-892b80cd6877	BODY	t	f	1.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	199947a6-3905-4cb4-94f8-40c79d1cee7f	BODY	t	f	10	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	f4584b7e-06e4-410e-a16d-8f2d07da00dc	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	1865febe-713f-4896-b0fa-0e94a712a29a	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	ef243544-60c9-4783-b8a8-cbeb698e2962	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	acc6162c-2e8f-4c29-9aae-a0eac56023f0	BODY	t	f	11.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	e65321a3-1dce-42a7-9e8e-656685042eeb	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	fc9ad585-19f4-47f3-9d54-d117a1ece88a	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	e4fc64e5-813c-402a-826b-ec44b7eb077e	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	7672b3d5-8c87-48a2-b1a4-6a5b7af12c31	BODY	f	f	0.095	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	23281bc1-adf1-44d2-bdf3-54b5f40e0f56	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	adcc920a-be09-40a1-89c9-e6e9aeb2003c	FRONT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	035f706c-3292-4409-8826-979fad725153	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	89e51f03-b1df-4ba8-ae2e-9dcb0a8ece41	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	b29b6a2a-6685-424e-af63-6aec6ab12c4b	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	07928752-afe0-4e25-b12c-669d98e536cd	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	0fc1f473-e450-44e3-ac2d-68073a7d6ec1	BODY	f	f	4.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	143ce6e9-06d3-4b32-b6ba-51c203ad7ef7	BODY	f	f	2	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	5cbe59d1-0bfb-41d6-88bd-d8f4c9d1ab5f	BODY	f	f	4	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	eb6dc0c9-d14f-499c-8d98-338d0b60d8e4	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	a1b03041-2062-4266-8724-d034221ffc1a	BODY	f	f	5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	a9f8b3b6-ba82-4f1f-b90d-635352b95af7	BODY	f	f	2	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	4dc2ea4f-ab92-495e-82cf-6c39bf8a4c7f	BODY	f	f	0	f	drone(remote)carriercontrolsystem	INNER_SPHERE	\N	\N	1	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	754dc562-e895-4c96-8ae2-3fc1b9edd897	BODY	f	f	2	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	8612cc2d-b38a-47bb-822d-eb464f1d083e	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	61565daf-fe37-4991-985a-624cba976301	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	9fc3ba15-7288-4636-9891-203fadb24110	BODY	f	f	0	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	2f771c75-b1fd-42ea-8253-4548cd162aaa	BODY	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	c23b604d-31c4-4276-8d61-156c6635ad29	FRONT	f	f	0	f	satelliteimager(high-resolutionimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	0f24f1bb-a08e-42ed-81da-4e1256172e7b	FRONT	f	f	0	f	satelliteimager(infraredimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e904-79eb-b552-460ed6242c3c	df923df4-d944-488e-a0e8-eddcc4d14e20	BODY	f	f	0.81	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e904-79eb-b552-460ed6242c3c	179061d4-41b1-4063-99d3-5cb84b1d47c5	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	155b28a4-674d-40f8-8d55-a3bc325f028f	BODY	f	f	11	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	97bad37a-8dfc-46ab-b3bd-c97701b79297	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	d24f8558-ad24-41ba-ae36-f7f73846fd57	BODY	f	f	14	f	crewquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	e23e8726-b3a7-4f4a-a826-08525a73cbaf	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	72e5328a-30df-489d-9ca4-3d6324c31261	FRONT	f	f	0	f	satelliteimager(infraredimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	57aee555-6dc5-4b93-8c82-38223f29e7d0	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e907-7d40-b85a-70a5c8b4fc5f	6f921758-5c71-491c-a208-18ac2e7e6dcb	BODY	f	f	60.5	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e907-7d40-b85a-70a5c8b4fc5f	b14e09f6-3944-44ab-bf67-288bae3a8eae	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e907-7d40-b85a-70a5c8b4fc5f	566bf217-ef58-4469-9dbd-b751e64e11fd	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90a-7725-ae3b-6fd6beb2e32d	561a11e0-581c-4b2d-9c63-76caded7357c	BODY	f	f	55.5	f	livestockcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90a-7725-ae3b-6fd6beb2e32d	c5775c87-d76c-488f-a39f-85a3b54d6a9e	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90a-7725-ae3b-6fd6beb2e32d	80800a92-ca0d-44e9-a268-82f05101419b	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	73b2c812-d5f5-4058-b225-2a3d74bfd2f3	BODY	f	f	5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	17db3c3d-02a2-433c-93f1-3832348cd653	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	45ece7d6-2b72-4b4e-987b-4f26379872da	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	6523e7fc-0f6a-48a8-8cbd-be3da841ba75	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	79ff0360-212e-4cbc-a7e4-5b3572e6e2b8	BODY	f	f	55	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	66b397ad-41af-477b-96d8-e3a3f546b0f0	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90f-72ae-873e-3d4014ac2ff3	2276e28a-4e18-49c1-b6ec-f3ae5a931d7d	BODY	f	f	58	f	refrigeratedcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90f-72ae-873e-3d4014ac2ff3	4910ff99-0445-41ee-a553-e0c6da91d4df	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90f-72ae-873e-3d4014ac2ff3	bae24b8d-a60e-44ac-9920-6de644b05a3c	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e910-7643-8852-814c6e90b4f0	cc51d8c7-2fc2-4fa5-8727-570ab63973c5	BODY	f	f	67	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e910-7643-8852-814c6e90b4f0	aca46207-a3d7-467c-8c69-17b9f821607b	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e910-7643-8852-814c6e90b4f0	f80fc97d-cde6-4e45-9465-6be089a33fbe	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	e27c2bb3-f999-4442-928b-2f06e31e07e3	BODY	f	f	0.387	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	e940d0fc-1696-4657-8319-49633a300335	LEFT	f	f	0	f	gaussrifle,light(kingdavid)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	12e5af54-0a21-42e2-9a2e-b109aa14f82b	RIGHT	f	f	0	f	gaussrifle,light(kingdavid)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	38992518-27c0-405c-b218-d4faba371317	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	fce18f16-b7a3-4f22-b8ff-0e89536c4226	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	e69894fa-4eb4-4d48-b145-e28727b0d816	BODY	f	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	14034153-4257-496c-9a8d-9b0127b2b682	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	b9c6ac47-c1cf-41b4-b170-8754ad3cd0b7	BODY	f	f	0.435	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	97f27475-aee7-40bf-84dd-54b16156a137	LEFT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	4f140cca-df38-4fcd-aa85-b7828f859bc1	RIGHT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	0c0daf00-ecfd-4269-bc37-8150714913ad	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	98283692-abc7-4c59-80ca-6fa5768f2f2f	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	6876ac37-6c17-4dc5-ae45-e0b44794ce1c	BODY	f	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	3909884e-b0ed-4dc7-8b9a-54c1b1c2905f	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e915-7783-b5dc-1e16b1dfac0c	8cd44c7c-0803-4c14-b0e2-b06a9aa036f7	BODY	f	f	0.601	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e915-7783-b5dc-1e16b1dfac0c	25011f3c-5b83-466c-9b5d-ad27368590b9	BODY	f	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-e915-7783-b5dc-1e16b1dfac0c	c523866b-d89a-4e47-ba60-40c9540ac3b0	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	4870f9ce-dc3a-4990-ab48-2abd1c1f5534	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	c97eefda-aa5f-4669-b1ad-22149af627fe	BODY	f	f	11	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	0a62c33c-4131-42f8-b5cc-9cacaf296b79	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	9ea1509d-2ba0-4c77-814c-5601c27d7c37	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	cd735125-ab3e-4a6e-a899-378c5820e042	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	ea48f895-cbd4-402f-9ef9-2fa7cad1c7b4	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	ed64cb06-f1a1-4f0f-9254-7f826d2a26fd	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	41e1045d-2941-4d1b-961d-14770076a3fa	FRONT	f	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	27650b67-5a4f-42ef-84e2-1f870ef0dbca	REAR	f	f	0	f	ac/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	9acffd23-bee4-4bd9-89e0-e4af43693066	REAR	f	f	0	f	ac/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	a261ba74-268f-471c-8f68-966c3905916d	REAR	f	f	0	f	ac/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	18e38096-3627-424d-b675-64ab57c8d7fc	BODY	f	f	0	f	ac/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	76316473-ee5c-455b-a89a-8d205efebcaf	BODY	f	f	0	f	ac/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	9e2f1ca8-341c-4d07-aadc-d6520cf3bd8e	BODY	f	f	0	f	ac/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	452cdd27-2717-4bfd-9d3b-16e290d60ba7	REAR	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	7246153a-d05b-4edc-8004-dd24e68db7bc	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	e6f37ed9-940f-4204-9125-ce69d8d1713e	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	22b42298-7f17-475d-9bd9-2b1b7cca80a8	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	917a7f9e-8446-4601-99d2-6a0ca3d5dc38	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	8cc2085a-7952-4204-8872-969bd5a9f7c1	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	1dbad39f-c62f-401e-81e7-9f1a2da9279b	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	323d84f1-122b-4070-a5d2-5d3525f95c5f	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	7706c225-7430-4d99-ba48-8c8a168cd022	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	9c3b8778-4062-4ecf-99ee-b063831df070	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	1b3aa5e0-082e-4f92-bc90-381f0aa91664	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	28f6ab6f-4be1-4e72-a8ac-0d4fa479a391	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	7fe5cc74-25ca-40f7-82ac-97ef170408b9	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	aed55f39-d53d-4bf2-81d6-c6be178b2f8c	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	d1d831f8-4b17-49f2-aa5a-991cee152345	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	8329effb-4564-488a-bbe2-4392457d8009	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	ee29f89d-8c3f-4a9f-9637-a28b11603ef5	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	a44c0d80-4e1f-41b6-b03a-640f0191ff20	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	a9baf01e-d282-404f-a54c-53fb9ed92ff3	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	2413e994-8baf-46f1-9aab-2f11c637569e	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	d495469b-a0b0-4c3c-bcc7-6f7355f9cf36	FRONTTURRET	f	f	0	f	reconcamera	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	1428e880-8f55-4188-8159-8523bbb08cab	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	9c5876b4-f8d5-461c-b602-4dde9c57d997	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	e86f5d8f-4d34-4151-aa91-0af4a59dfdfe	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	4819ffe6-4fed-4ca0-b9d0-c87de331b122	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	a66b51b4-32d6-4462-8c1c-0aafa66ecaf7	REAR_LEFT	f	f	0	f	anti-missilesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	6ede583d-1bd1-4453-afc4-3d6f6ee11f72	REAR_RIGHT	f	f	0	f	anti-missilesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	d6c4cd54-6371-4e89-9165-43712ee29b93	BODY	f	f	0	f	anti-missilesystemammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	c5010bf1-c276-4b65-a4a6-6d0a30a3b6de	BODY	f	f	52.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	aaca1616-4427-4073-b530-bf65c592f048	BODY	f	f	8	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	20cf908e-a2f3-43f2-894c-76111f8c5b47	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	ae65c049-a22d-481f-a4a6-34d31587774d	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	c1a00939-28f9-4de5-bb50-83cff52caaea	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	3701680c-8056-4b5c-a61b-6b9a18e3928a	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	5baac116-fedd-43ca-a95c-3498acb574ab	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	cfedd94c-c755-49c1-91d7-5770fd229f61	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	f21c3ead-17f3-4821-ad45-2ba2bd4684ec	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	0c11e0c3-8239-49e4-ac05-e5a3d1a0c7ec	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	30b8372c-2100-4071-ab4a-4799841f86f7	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	39f48a81-8378-4eb7-9303-d0cac7ccc305	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	6734ff8b-8e73-4f1d-83fb-126180a20f61	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	7ba8f7d1-299c-404a-88b9-88d7e599c9c2	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	7e4eade8-6b6d-45a6-b929-62dc4da87c1a	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	da3ecbbe-8b10-45a2-8b73-d08261a2c3a2	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	e5730a69-4c41-4f7b-9524-0750d1e0b704	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	ebd418ce-3db9-4831-b47f-ef2dfc5ede19	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	fed12d0c-535a-4f33-a0df-5aacab420699	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	67eb9a07-68d2-4f77-aff8-70f981ce8c05	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	d2fdd082-3c26-45ed-b990-f12e2c403147	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	9cd739cb-add8-4bfc-aa77-c5cf601a75bd	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	7d9103ae-615a-4413-802b-696e7db58067	BODY	f	f	0	f	mediumrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	c8acfac4-3521-4051-9a99-8133191868cd	BODY	f	f	0	f	mediumrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	cacdac26-7e6e-43f2-87d4-d18b9662062f	BODY	f	f	0.125	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	76a77f6a-e842-4bd6-801b-71a00c112222	FRONTTURRET	f	f	0	f	rifle(cannon,medium)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	b851f8ef-ec37-43f1-8eeb-37009df72378	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	c8f797e2-2ee4-4234-ace0-17649069cb9e	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	f3ff40e6-88a7-426c-8df7-f32d826dc19a	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	03156db5-620d-4e14-ad18-f6d9e01756b9	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	caf066c6-f9cf-410a-ad8d-1f300e173bde	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	52e7c8fd-77ea-4954-9471-5da03e703b84	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	e1893c18-df12-4f4e-9180-0ed90750af9e	BODY	f	f	0.125	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	2072b9b0-56fe-49e6-91ae-b2b9c0eff235	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	fdc3d080-417d-4ba1-88ae-c5fa4a50360d	FRONT	f	f	0	f	combine	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	2a059341-7c70-450b-80e9-10b400312f37	FRONT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	84df6986-c4fc-44cc-a5c3-a0d49ff4adfc	LEFT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a46c2e5b-6373-4074-bf6f-45b449182a3c	LEFT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	e78512fe-329b-4522-bd27-d4b78fcb2cce	LEFT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a9468f6e-a209-4e60-8034-0b4494e4ea25	REAR	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	d1b6dd0b-1aef-4ceb-9168-207a7ae1caf0	REAR	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5205adc2-a086-43c9-8dc7-800bbbf7704c	RIGHT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5bb6d97c-4994-4627-8529-1a2c6d41c2fb	RIGHT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5dab60d2-52aa-40d7-812d-2419e936985f	RIGHT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	496ffc8e-eab9-42d8-a378-f51845b061be	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a99b1cca-dcb6-4ca3-865b-3991f4766e08	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	60658742-c234-4f7a-8f1e-3ecc8937e591	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	9feca6d0-1484-4020-b253-2745eece7ceb	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	ad06857a-3498-45f0-a7d4-1111df998927	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	77cea2f9-380e-4133-b468-2baa0fbbd551	REAR	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	4c885452-097d-4df7-b092-fc768ee69d7c	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	8a083391-db48-4775-88af-45b931b90d93	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	e1ea8a9c-70f7-48e5-b5cb-5969c624121e	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	2fc11cbd-30ce-40a5-a4f8-4d4d95f1d791	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	2fefd52a-4305-437a-8341-f6dd82b8ade4	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	394b5af5-3922-45df-b7ac-70b74bcbe28b	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	63537d62-74e2-4d15-8338-330f5cbc6a06	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	67c71edb-94f4-495a-8df2-83ad77cdb8cd	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	92a2ab5d-e0e7-4e4d-9af6-c519c30b990d	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a3854bb6-39b3-4f37-9b6f-28662be765c8	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a6e05321-427a-467c-b0a6-4972f0624987	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	cc6bdbc9-a268-4e47-9bab-981a3f4f1432	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	d7a1c50d-8741-4c57-827a-674f5c5e05a5	FRONT	f	f	0	f	srm2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	16c0db91-ad6c-447e-9cf2-1a48e5fcb59c	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	42ebd57a-1eba-4d51-b5c7-e944d0a4bf0c	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	eaadbaf6-234f-438b-97da-15bae7b32ebf	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	30568864-79f8-4173-b947-93c01e094278	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	3c326c69-5029-408d-9539-45ec7aa8f31c	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	3d1987d7-404c-43de-b244-94eb69b61c9a	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	439b92e8-4c84-407b-b15e-66daee7df250	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a512a153-15f2-4718-b1ea-c1f5aed59e00	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	ad35a76d-b053-4b5a-98e8-85ccf1160cab	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	b113414d-3328-43ca-aae1-832457fd9dbc	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	d0368086-2985-4873-8793-eaa57990eee8	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	dfe30fdc-135c-4178-b7c1-25175351807d	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	5fc0d036-a3b6-48a2-9b20-ae05cf399b02	BODY	f	f	0.234	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	96ca41f7-2a87-4a0f-88ec-f4c439e180b1	RIGHT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	c5988251-9c1b-4497-a142-de1ea15fbc33	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	f948adb3-cb0e-4214-8cb0-fa3b6ccbae46	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	9bf86fc1-cd52-4a2b-8d3c-0464c9b635d4	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	0e0c1c88-8cdb-4697-b372-2dc1e68a1d40	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	33f867cd-8956-49af-9dc6-f5bb2463f02e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	77bf5371-40fe-403d-b998-9fb49b4b2fb6	BODY	f	f	0.062	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	cc296484-9df1-4bfe-8b55-dca32f3e6110	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	e6f36e56-e08a-402d-9860-c746bc96a9c4	FRONT	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	ed701548-7ccb-4e34-8c5a-f3c5770e027e	FRONT	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	c33fb122-5200-4ba8-8da1-5576afe7f93a	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	4f4aa937-45af-4f02-9442-71925f9fac69	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	64e14a0d-55b9-4f06-a7ad-b63b894274d3	BODY	f	f	0.062	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	37362731-742f-4f14-a144-88b3c5347dac	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	817ce62b-a6af-4016-abaa-46e87b113d26	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	5cf39783-e32f-46c8-95e0-ac8c0d885901	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	a77adfff-4a28-4bd5-8a25-4704b17757c5	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	989e8c0e-ed0d-4897-a33f-98af5f0224ee	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	727c5c32-e679-4eff-a347-518c3c8182ac	BODY	f	f	0.062	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	cc21f98f-700c-4817-ad86-1dace16c7d3c	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	30fe4681-5716-4e92-8ed1-f2e08de17394	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	46a17824-6a11-4399-93ab-cba0ad1f24d8	FRONT	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	339f020e-0a0e-4f67-8638-ff494b8e8cb9	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	cc484135-c546-473a-b28a-fc3493b078db	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	9c5fa3d8-600b-4b15-a6a3-ac1d9313d958	BODY	f	f	0.021	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	a972d662-bf10-478d-b10c-fb4bd92980d0	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	47e05f70-8726-48c5-8ea5-86add4b558f5	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	4c9143ea-5581-4736-9d57-726c479cbacc	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	518c33b9-c0c1-4cd2-a7c8-08f3de4c1431	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	9233bb7a-04a8-4117-a7e0-513562bb093f	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	f2120084-9a0b-4c2d-b09f-11cd68ef0aa7	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	e9399118-c771-4f27-b82e-b997357c0fb9	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	99ee184b-0294-48e6-bb8f-5b28b3befa7e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	0e559a2c-0234-4b56-a6ac-072ecd0c309c	BODY	f	f	0.02	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	72cec0fd-5642-4206-97ef-57eda863ca2e	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	ab33914d-2ae6-406d-9d7c-df6995e99447	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	8849f529-32a4-4db7-b528-800ec114f3d1	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	7b9cd601-1584-44fd-8bd5-09b720343cfa	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	1f0b8a23-a211-4699-9971-61e79f7fb6ad	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	416f21ac-70d4-479b-a48a-22682a2f5064	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	5f9eb0c9-3a58-4438-bd23-6e790ea2b25f	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	9b56e72c-8ae7-4232-a344-a08b32fb8e2e	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	a1c7a43f-271c-4371-97a8-9705b6e0e81a	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	d3fd99c3-d268-4b14-8070-1d148586c854	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	6d95d261-9fe4-4a76-b062-d7ea1bc1de68	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	798ad6ba-5975-45f9-b981-54d9840b8692	BODY	f	f	0	f	svchassismod[monocycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	f4469747-62af-49ca-81f1-8df61ce663b1	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	295492aa-e605-483a-a03b-44b32e20bbcf	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	14fab223-54fb-4bb9-8c30-c36aabceb41c	BODY	f	f	0.15	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	1073b907-dbfc-4a1d-be6e-de10951e280f	FRONT	f	f	0	f	grenadelauncher(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	c53d226c-4103-4817-b2d5-116e91196891	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	8119cc28-4a0c-4679-a9b2-40d1339b1e88	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	63717de3-b0d1-480a-8c86-4d1759221073	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	00570649-1ed1-415e-ba8c-2e59f8ed7593	FRONT	f	f	0	f	autocannon(semi-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	07d82c83-1c0b-45fa-b31d-cd27a49f27bf	BODY	f	f	0.405	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	2b224230-80fc-41be-a7d7-4315ccee4ebb	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	3345a94a-0c59-443f-8d5b-e8499c2da68e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	9124ce27-d381-498e-bf2d-07bdaf600abb	BODY	f	f	0.06	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	18411b5c-29b3-439a-a01d-ccd98a356998	FRONT	f	f	0	f	heavyflamer	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	1ea659ec-9bcd-40b8-a3ed-59eb21e8a925	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	909d8ac7-4f49-4dfd-9fa5-e66a958167ea	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	0696546a-ecd3-408f-a82e-8513f97e8429	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	152d6a58-0d4f-4129-8763-1420bdfab379	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	50a95825-24ab-4a05-8eb8-5c2d3010bc65	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	942e2896-80c3-49dd-bc18-bccf607e05f4	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	25da0c71-60c3-418e-a391-02a6f92d8b01	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	7441daa0-6283-4acc-a87b-7b38ed0d4f45	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	ff2e5362-5598-4ecd-9dc9-188ebbc90f87	FRONTTURRET	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	2eb170ca-e4ae-452d-8ca2-0886c75c766b	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	bee667e3-1bb3-4551-b133-819efbb4dea6	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	8ceec1df-dfc5-4329-b6a8-c46ebc2ae641	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	a68a784b-a902-48cd-ab34-f653f718962d	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	a817d76b-40f0-4664-bc1a-c2ecebbcf9d2	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	5608761e-d822-4bbe-b37f-851f07b3fbf7	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	dc3088f4-0678-492e-bb58-18783121ee33	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	725fe6bd-5c9f-45ee-b0fd-8692014e7556	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	29dfdbc5-2b1b-449e-a5a7-8796f8403660	FRONTTURRET	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	c6384ad4-0845-44b6-800f-05e971511d6a	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	1f8b2e9e-4867-4285-bac3-a57f563fde47	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	4639b425-06e1-4efc-ad6b-ff56c6b3acd9	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	e24e417b-8e1b-4c09-b451-a6a40c0aad36	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	f18f4f91-33bd-45f6-a2e3-3de2e51eb199	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	06aae360-5efb-4450-b0c7-4121cc815494	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	ef56cf3c-d235-4335-a1fb-52c9fa285a2d	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	821bc871-b0e7-421f-a69d-82c263093920	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	b78c6733-cbc7-4c99-aff6-e8aad0b9245d	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	a5b859e2-17e4-42bc-96d1-225bbd5fc91a	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	226ff8e2-14e0-43e0-a1e1-06e23b7050f7	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	cc9666eb-203e-49c4-8a3c-6ed6d4470094	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	261ac5d3-854b-44ff-9bca-9efe78c3d25f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	2e5fde00-a018-4cbb-86a1-f75dfdee821a	FRONT	f	f	0	f	lightgaussrifle	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	04f80462-85f6-4eb8-858c-7fbe7edf2f39	BODY	f	f	0	f	lightgaussrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	285481c2-fdcc-4026-a694-96232d4b8c32	BODY	f	f	0	f	lightgaussrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	d18ad5eb-ab13-402a-b80e-6d55fba08cf3	BODY	f	f	0	f	lightgaussrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	57d76f48-f69a-4e11-a6f2-6b2206500d8f	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	b555c97e-caf3-4c7f-918f-a0ffac58c806	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	64bede5a-237f-436e-b55d-4a1dc1647c14	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	78e49cdc-ccf5-49bb-9a49-485af8e13564	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	d3608fa7-71be-42b9-8ebd-ac95508c3139	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	5fa2a639-bcea-41c6-a3e8-ba65660a221e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	c0c7011e-0ec2-497d-b4fb-95cc7a1626c4	FRONT	f	f	0	f	lb10-xac	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	b7b68a21-a786-4863-9c11-141d0daa9cd6	BODY	f	f	0	f	lb10-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	fc7cc6d4-a541-4ca8-9701-01e329f8c6e7	BODY	f	f	0	f	lb10-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	bcd0679f-0162-4452-b2d8-0e83496d5a12	BODY	f	f	0	f	lb10-xclusterammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	ff5709e5-7fab-43b2-9152-75148f67c98c	BODY	f	f	0	f	lb10-xclusterammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	e5b77b9c-39fe-4f06-b626-e7e3e50d15a9	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	1cfb7e6e-88a8-47e6-9744-84bceb1c9887	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	707ab974-39d2-41df-8b11-1c6338130ef1	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	d48873da-eb20-4934-b909-6f7fe9c27d2b	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	ef77ad9e-ff07-4705-b331-dbc7c0984f7d	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	9e935907-5765-43a1-a2e1-b8b96bfd8ed6	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	876315f2-61b5-4383-84b6-22f9db2880fb	BODY	f	f	6	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	eb9eb740-9074-486d-b05f-a769d9be1a5a	FRONT	f	f	0	f	lb2-xac	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	297dc6e8-2914-4015-9e75-937f8e8baba4	BODY	f	f	0	f	lb2-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	6633415a-8754-4a00-aa33-23e2ac3e8ef7	BODY	f	f	0	f	lb2-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	81b3f8de-65af-421f-9aa5-5ff359a00219	BODY	f	f	0	f	lb2-xclusterammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	f9b9db79-2d05-4fbe-9690-cc6f65e03e19	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	e8484aee-1db5-43b2-a7c5-3bcbcd634697	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	2865eeb1-3751-48b0-8f07-2455f2a27a59	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	49a21cd7-bc2e-4474-a724-e87ee031e733	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	764cd791-279d-4f27-b208-def6edaa2356	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	b731b7e5-b2a4-4fc5-b569-e7fd4496131f	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	241acc85-d60a-4084-9f88-c9331a5648d6	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	eccd7223-d1cb-40aa-ba57-74316ca337a5	BODY	f	f	3.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	3f0def26-8eee-499d-a064-13567ba18470	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	318e7485-6f7c-4549-b7e9-40d102d9856d	FRONT	f	f	0	f	rotaryac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	05907284-61be-437b-9f27-75c273399f85	BODY	f	f	0	f	rotaryac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	c8b84ac1-c607-4c06-84db-9bc225168acb	BODY	f	f	0	f	rotaryac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	cebe32cf-c464-4716-a23d-015b95c4eabe	BODY	f	f	0	f	rotaryac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	380e5eb0-d071-4535-b990-263c098822d4	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	2b9f1761-d08d-4a88-b5aa-92400be69e76	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	0e4f45fd-38b7-4fb5-b3d5-d2b1bb2c4387	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	2339a3c1-8f07-4460-b346-1f6c9f8acd5a	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	8dce2d9e-7d56-4cf8-b701-2a41da8e070c	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	b2520d9d-5038-4514-9dff-efaa5f587ed3	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	752b5fbf-0710-4e80-9e01-26f946d1fe6b	BODY	f	f	0.068	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	48495f7d-f8d2-4e13-bdca-f279fa848ea4	BODY	f	f	0.05	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	d16be728-6ce2-4243-8e44-24c512a8404b	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	3bef27fe-c8bf-4804-9abd-b83681a6f7aa	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	3a30fada-12b4-4cbc-a8d2-14d3cad143e9	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	5eeefcfb-b605-49b9-851c-65de3229a634	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	9dfb6c6c-3d93-4e8a-9531-442350ef27d0	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	ac0df0cf-45e3-4d73-878a-31a668c566f2	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8f-7da6-8321-6f2f6dbbbc80	63e2286c-202e-4ca1-a022-13fb38fa02bd	BODY	f	f	0.214	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8f-7da6-8321-6f2f6dbbbc80	00dbfdb5-6f38-4929-a066-665a1a61d70d	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8f-7da6-8321-6f2f6dbbbc80	819475dc-b619-4a86-b028-3e9fda98f76e	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea91-7849-8b93-ca87e63a1f10	c4fa392d-dca0-4d43-b763-ccea61ffad1b	BODY	f	f	0.053	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea91-7849-8b93-ca87e63a1f10	28954ea7-9a38-495d-a347-0da0ad340c87	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea91-7849-8b93-ca87e63a1f10	c250759e-6830-49d3-a638-5ea7287863e0	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	5c8e2b9b-6b6a-465e-894f-42f1df47a4b8	FRONT	f	f	0	f	activeprobe(beagle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	7b43e087-35a9-4305-af0b-a4b21949992e	FRONT	f	f	0	f	anti-personnelpods(a-pods)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	6e149a6d-fba7-4c79-a41c-f5493f6facad	LEFT	f	f	0	f	anti-personnelpods(a-pods)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	c9931656-f643-439f-bd12-cb571890720b	RIGHT	f	f	0	f	anti-personnelpods(a-pods)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	b7755443-ce52-4795-8180-86d6f19f17e4	BODY	f	f	1.55	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	ff3f8024-6969-45c8-b847-51b5a0f46aa5	RIGHT	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	a0942fd5-9a90-487f-9e61-569f5fe9e339	BODY	f	f	10	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	c65f09aa-69e8-40fc-a907-2ebb2f20f15a	BODY	f	f	0.034	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	bae1ccf8-46e7-4058-9c87-70eadcad1adc	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea97-7e69-b5a0-da6c266d4fb4	74c9e328-dad8-43cc-bb11-70382f415ad9	BODY	f	f	6.05	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea97-7e69-b5a0-da6c266d4fb4	7573fc66-4d91-45d9-92d4-55075ec3acc4	BODY	f	f	10	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea97-7e69-b5a0-da6c266d4fb4	b6b45063-bbf5-4cb7-bfc0-a4e28a0f8d05	BODY	f	f	0.034	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea97-7e69-b5a0-da6c266d4fb4	25886988-c0b8-41d2-85da-3d66bcf70eb0	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	927ce312-9db3-4523-902f-7f754c1f32e5	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	65ff6604-113c-4948-ac4f-51701f8d5477	BODY	f	f	5.275	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	388af852-f1e0-45c2-903f-2e1cb566f169	BODY	f	f	0	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	c4e159b5-9d64-47dc-8251-974d016c51d1	BODY	f	f	3	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	3fa031cb-65b9-439a-bdf5-ec9e498c79a5	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	f50b602f-d4ce-41cb-95b8-7b3e3ff394b0	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	ea1d8913-1919-43a6-95f4-98a9035dea20	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	08a45e7e-d6f3-4add-8605-3965191f162e	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	855ce8bf-fcc2-411f-ab8d-a0858449cd31	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	a37a673d-9d2f-4017-b5a8-1594a5607c88	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	f93baae8-28a2-4e89-a788-45089bb02273	BODY	f	f	0.073	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	1c08a46e-c2db-4685-81a2-6f27c6465a2d	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9d-76b7-99cd-2165b9e79aab	94525812-a431-43e7-b7b3-33df953561d8	BODY	f	f	0.304	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9d-76b7-99cd-2165b9e79aab	b292985b-3947-4040-bc37-e6769fa3aa03	BODY	f	f	0.3	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9d-76b7-99cd-2165b9e79aab	840bd24b-4647-434f-8d7c-836b365b51a2	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9f-756b-a692-9527ec3fc049	0cf3adf4-8886-481d-ba0c-716cdf0106e6	BODY	f	f	0.2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9f-756b-a692-9527ec3fc049	0345097a-b20b-498c-8cc8-56e99c803e3e	BODY	f	f	0.023	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9f-756b-a692-9527ec3fc049	d815e736-c2da-445d-a26b-f15a3085b808	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa2-7bd2-93a2-4c8ebd3527eb	d9a3e4b4-3804-407d-8211-c705d1aa894e	BODY	f	f	18.05	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa2-7bd2-93a2-4c8ebd3527eb	a7f86027-0332-418e-bc22-81891a99ece4	BODY	f	f	6.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa3-7d11-b1a0-aec3057334d2	538adf3f-ad9d-49ce-abf3-91c48e4ffbb8	BODY	f	f	0.085	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa3-7d11-b1a0-aec3057334d2	05dcb2e9-84ad-487e-ac78-69dc6ed1375e	BODY	f	f	1.05	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa5-7454-8517-0af434784a6e	67f6756f-b9b3-4440-bdbc-b51e6a56fffb	BODY	f	f	0.009	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa5-7454-8517-0af434784a6e	ad92855a-f0bc-46da-9c2a-36069ed4256a	BODY	f	f	0.3	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa5-7454-8517-0af434784a6e	5596b684-a323-46b8-b5a4-b51d790619d4	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	e4fef5d3-f566-4ff9-9e2b-43cd14089c3c	BODY	f	f	3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	3fbbd2c4-e45d-4d68-a423-761500529240	LEFT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	634e5257-9db5-4c16-8e9b-e8e6a0acd7eb	LEFT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	7d3a2388-cc55-4803-8371-d38e4638f8bb	RIGHT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	d18a1829-2624-47a4-bbe7-18159e1a3911	RIGHT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	bdcbd2d6-5e1d-48b7-9042-93e7503346e0	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	e1c86e41-a244-4071-a8f4-86b3ae8da666	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	f4adc762-121c-4073-bd7c-cc3dd814b533	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	c08efec3-6934-4aae-b8c9-703876a916fd	BODY	f	f	50	f	lightvehiclebay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	9c22897c-de73-49bb-a4de-015bfe5f2057	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	bd459870-e5aa-44c6-b1a0-d107b8e73c6f	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	c54c2a9f-3ba5-4af3-ad7f-82129cd44b91	BODY	f	f	1.5	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	f50fde7e-418c-4469-a03c-f5ff2099343a	BODY	f	f	10	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	b6a5c14c-b164-4426-ab06-0925e2105c5f	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	31d1e825-2638-4a24-b833-bd449099bfb7	BODY	f	f	0.194	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	387b37e8-ea8d-422f-9cb1-e66c3e1b093a	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	aebc88c9-7553-4ed3-9874-096764faa4c3	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	b0ea142e-fd01-4710-ad52-e824d0c358ca	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	73ad6758-982c-493d-96ba-5b413a3bd1b1	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	f1651ebd-4c4f-4c20-a352-cac361317eb4	BODY	f	f	0.225	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	925caba8-397e-43cb-85ea-7d89d3b7d791	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	89dbc1ae-1f5a-4f1b-be79-0931697d333b	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	6224c9e9-b120-4699-b6ea-8dce33866df0	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	bf8e117d-5ed0-4af2-9996-0a320d17ca3d	BODY	f	f	84.55	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	9024e72a-b23f-40f9-a294-83ed88144837	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	bec7fc73-2a19-4fe3-bee5-1365f6f9a0e1	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	0fb0b4ba-de70-4c7b-add1-397d54642b6c	LEFT	f	f	0	f	lrt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	4f06a03f-6cda-4f81-abda-fb9139961853	RIGHT	f	f	0	f	lrt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	c00e1c85-ac8a-4f3e-81df-c2cfc8908ff0	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	d5a0c376-2d85-48e7-a5bf-3160bd19c46a	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	d9faa600-0250-4726-ac33-70d9e9c70d77	BODY	f	f	0.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	1c5f0224-1167-4063-8e44-12ae32e58c23	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	30dfe064-d5f9-4e69-854c-cefe315d3002	BODY	f	f	7	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	fdbdf1ce-e4e3-4dcd-be67-06d01616709b	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	8e3c09ad-9520-4d51-ab34-c0a4ec7f8740	BODY	f	f	70	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	85391ff0-a5e3-4aa5-9e76-55c7864d7e28	LEFT	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	a530d492-c95c-408c-ad56-f9df9f40e239	RIGHT	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	646cb329-d289-4f53-8a1e-a06f67f76829	BODY	f	f	14	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	5fea39fe-62eb-4634-81c7-1c2be25cf6da	BODY	f	f	35	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	9c0ae8b2-2f75-4096-b54c-50fff78ac3a1	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	5478b804-f4d2-473c-8a27-1c2161fec79c	BODY	f	f	1	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	dc450246-d3e2-4fde-a062-25fdefb2a1bc	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	c5470c1e-c20e-4680-9f57-bb1fd5f474dc	REAR	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	118af446-9a33-4622-80df-602efc7a597c	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	97190dc6-7064-495e-8764-1f73791c927b	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	ce9746de-58ae-44d6-b187-65b417b09e1e	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	921cc93f-23a1-48da-987d-e813e611c954	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	f822a593-cc62-477c-a0c2-aac86058e866	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	0425ec6c-2645-413c-92cf-dfe1185eacea	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	849eb108-965d-4693-8b03-e7abf9fdd273	BODY	f	f	0	f	svchassismod[hydrofoil]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	202422e2-e030-4b6e-99e8-9f919a0b8d6f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	5c0ca64d-b3e9-48a6-8ac5-f34f661e47f7	BODY	f	f	1	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	23387be4-037a-4b3c-9025-6625902dd537	REAR	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	33bd83a9-4cd5-41de-9d84-86ec8ec10f04	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	06280457-0095-4f50-a10f-59c1b697045a	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	dc4b5631-a4f7-44e8-88b7-39f23940eb2e	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	d0766f36-1348-435d-9a84-431e1850f2ff	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	3984a8f2-1394-49fc-b65b-14565baba4b9	FRONT	f	f	0	f	srt2	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	fef7ed6d-2af5-4181-a5f1-d28bed33be2f	FRONT	f	f	0	f	srt2	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	0ea6c44b-1fe9-449a-9af0-53f822fa84d3	BODY	f	f	0	f	srt2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	592c0f80-6b88-4dcf-b381-4af03515c1ce	BODY	f	f	0	f	svchassismod[hydrofoil]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab7-7393-aaa2-212bbb5a8a3a	de196fe3-0107-4923-bd05-54db3d957a0e	BODY	f	f	0.009	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab7-7393-aaa2-212bbb5a8a3a	ba4f1edf-8f4a-4d4b-ad9c-b6d56f110f24	BODY	f	f	0.05	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab9-7eb7-92ce-33119b5fd7a6	825aa346-b4e8-4789-a600-360c6ec6a5bf	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab9-7eb7-92ce-33119b5fd7a6	c6cbd315-7b78-47c7-85e4-d3650b2382d8	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	ca708d60-1e52-4d2b-884f-86b9338ff0eb	BODY	f	f	28	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	4a88577f-aa72-49db-bc28-bdb0fa0242e1	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	b54be955-9e9f-4fd8-af49-f0e5effbe2c8	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	d07cc409-c658-49bc-b56b-7cc203332cb4	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	ded45686-3194-43a5-a43e-9240248b8097	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	e9c3feee-3c1f-40d7-ae2a-0be2b18950bd	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	9913c4da-ef53-43c9-8bd6-b8d5a2b14b26	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	bb03c85f-e768-44cb-aea8-f9a77ae949e3	BODY	f	f	1.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	fd168ae0-1064-4fa5-9b49-5cb74baf332f	BODY	t	f	70	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	1db35e60-afde-478c-802f-d49e901ad59d	BODY	t	f	30	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	9372f0a2-1b33-44d8-9be1-ef409f8e6091	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	cd8ee3b8-93cd-4258-8731-2199a190613f	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	bcc2b348-5172-4d72-82f5-f93820dc6c22	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	2b4f2327-7623-4998-90df-3d5ba4625776	BODY	f	f	1	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	1f4c0f49-4a93-4ed3-a23b-7148e625c151	BODY	f	f	30	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	7e238a6f-6d68-4da1-9586-4c5e0dadcce4	BODY	f	f	50	f	lightvehiclebay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	0c1ba026-280c-4b66-826c-cc02d616c721	BODY	t	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	ebd6b363-7a5d-43d0-baaa-28a01233aed6	BODY	t	f	0.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	ca7bd327-c4ac-4f9a-af47-1aefdb913ca3	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	965e58a8-a8f1-4b29-8392-641beee3f04e	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	b01ba498-39a7-4a2d-a4a2-94080dffee87	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	361b76b5-9044-4e59-acd7-f8dad1f034ac	BODY	f	f	87.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	81b18462-b79f-4fdf-a0d6-58eb5bd577bd	RIGHT	t	f	0	f	dumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	3afd4a66-0597-4bf1-adf2-388a82e193af	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	64fcbb6f-80c3-46d1-9edb-124497fffbf1	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	9048a615-f639-4625-bfea-769c95250f5a	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	a0492594-63e4-4376-9194-40a01751f896	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	2af1c65d-075a-4e87-accb-abbc64a0f4d6	LEFT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	094a05b0-24d4-47ca-83b6-49e8d01e9026	RIGHT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	c328a8a6-e5d1-47fd-8525-6db0de914a15	BODY	t	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	15fce36c-d7f8-419c-92f2-67ba28f456ca	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	264826fe-bb93-4399-8f0c-524ab86bb961	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	65c25eb0-b4dd-4401-b379-386b08293a00	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	b41bb725-4f3e-4f87-8fbe-34988b71ad38	BODY	f	f	6	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	8091ccbe-0708-485f-917b-aa8b449d26ff	BODY	t	f	3	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	0d979867-57d1-4332-82a9-fa1a747bc5ab	BODY	f	f	50	f	lightvehiclebay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	c7148a73-9a53-416a-af59-d2001fb13fa5	BODY	t	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	5
019f583e-eac8-7be2-a548-c275acaa1e23	ce6e782e-d6e9-4c4a-9c4f-b528aa4639bb	BODY	t	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	f87434f1-f029-44ae-82b4-0b2563c5bb5e	LEFT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	57fe15a6-acc8-4417-a00e-7ae63108566f	RIGHT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	b746d067-823d-449f-9d6a-c8473d18c50d	BODY	t	f	14	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	918b1a2c-5864-4292-bd13-e262afbeff7a	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	dd3658b6-4111-4d14-a891-fa853c68e420	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	1506232f-a003-4f3f-b687-e0c0385f9c58	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	a0b6b8ea-3fa1-41a1-a896-820ec4116c3c	BODY	f	f	4.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	cfc0cb83-2922-4f12-bdc2-a543e30585d5	BODY	t	f	90	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	e1048151-4d06-41c1-8221-32d0ef13a3a8	BODY	t	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	eb30de0d-c9b7-4a40-b9a3-eaa73b1af1b1	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	960fa152-d081-462c-92e3-447413c80a94	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	bc57c7ab-3130-42a5-88e8-46b00e798a03	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	5f6ba6bd-a091-4a93-a9e4-e6252833e5a6	BODY	t	f	4.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	7d264f81-2872-40fb-8410-d3e69e5bf778	BODY	t	f	90	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	2cc298d0-aff0-4bb1-a0d2-0f0b6d5d1b5f	BODY	t	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	13b03f17-987d-4140-8366-2a34bb4a9fae	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	3643e00f-6481-48e9-9bf0-0c3883131c10	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	69114891-6447-44e3-9a49-520a828b2bf0	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	5236e784-c49c-47a9-aa3f-21dc3fffbb6f	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	a964718d-c3f4-4ddf-ba7d-b3638c9639b0	BODY	f	f	0.869	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	c57e65bd-477d-4fa1-9f56-9ab66bff5191	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	8ebffa28-a968-461b-a8d5-517fb1e37491	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	8a7b9a24-9773-4619-895f-d80165bba39b	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	f664a4e9-e3a4-4675-8582-d30e6b04bc7c	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	ef483a7d-df02-477b-814e-c9134d912635	FRONTTURRET	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	81d21f2f-1968-493f-acd3-215aa1dd0ed0	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	45d9d8e5-7281-4e37-9d34-57ce7e89e652	REAR	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	f7e5b5b3-3bf4-40d3-9f31-aa3ca0f70c41	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	70d77744-6ec9-468c-8d7d-53b58c33c79e	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	60edbcf2-5ee5-468a-bbea-3e4904381ec9	BODY	f	f	23.591	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	9536edbe-120e-4b79-9eeb-34c834a5b60f	FRONTTURRET	f	f	0	f	miningdrill	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	93e57db9-348d-4fec-a521-6aff669a9728	FRONT	f	f	0	f	rockcutter	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	097e1f7c-a7aa-4a29-b6ca-de7df5992574	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	77f3a62f-9847-4230-b0fd-b6fee30fb952	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	11795347-72f3-4efe-9ae2-db58fb2ac0b2	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	e41a9c19-6a59-40a3-bfd4-7e3d1dfe4ac1	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	05f31e59-e42a-4f23-ac38-6162a3c1f704	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	bea63ec6-b34c-4348-ac59-f37c3ee86743	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	75553ddf-9636-42fe-a6aa-62d835d38b0c	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	7dc544ff-53ba-480c-b6c4-7092b95599ab	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	bf3cdfcc-8a2c-490f-b732-423011108bcc	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	cf1f8861-a2f5-4491-846a-2c1d8ce0b7d8	FRONT_LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	cec02df3-fb4b-4c3f-8abf-7e2118e5cd9b	FRONT_RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	de076e0d-7b9f-4037-8631-c29944d86e75	FRONT	f	f	0	f	activeprobe(beagle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	0cf879a1-dc6b-46aa-b912-389e4fce760e	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	424b349f-5685-4e9b-8147-f34c4d263edb	BODY	f	f	8.92	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	ae0a8c29-92e2-4785-bc4f-65905729a9f0	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	82ca908e-e9a7-4de2-af6f-a5e98c8dd5a6	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	3681668c-1465-4149-89ee-293a5373c0c5	BODY	f	f	5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	4781e658-8c24-406e-adeb-457d3a90fdf4	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	50bfb196-43a1-498b-9a7f-b2556444769e	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	66ff7510-3724-49c9-910f-f09b2a7a7c30	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	d95dbbf6-11b7-4140-a133-9c73168134bc	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	81d3d6c1-3406-4b03-b61f-ae75e4f81618	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	98cd8066-bac5-42cd-8e75-91058ddb7b36	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	ee5e2def-16e7-4d5f-bd46-6cc145154890	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	7c923ee5-15eb-40c8-8517-2433c7c6ff90	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	c3737933-7995-4628-a5cc-e3acb0dd7165	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	d072b8f5-7704-4536-8b9b-85e07bfa8b41	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	43b1f718-5663-48f8-b401-fe2cbe03b7ba	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	499d5ccb-6c98-49fb-912f-463c6f414e3d	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	560d37e8-3608-47bd-bf94-33ce6129ae81	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	0c1ff3f9-7bd1-4e5d-8d9a-606169db9ed9	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	e8f52bf0-d333-4510-9ef3-948b57480ba9	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	fca4a427-dd61-4538-87df-95232d9ec2b5	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	e3c20b86-6c8b-486f-b47b-734090d57958	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	a6857f47-3285-488b-b3ba-a99c5d32e747	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaec-7b17-9b33-5c0e62d441c3	627c5119-188c-4503-bb90-39b867570942	BODY	f	f	88	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaec-7b17-9b33-5c0e62d441c3	df1f6295-696c-488b-9a08-720a0b38f8a9	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaec-7b17-9b33-5c0e62d441c3	91ee06e6-16c7-4c0a-9e59-ffd455dba979	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaee-7a62-b46b-a0cfb832b36d	f61d5f69-a59e-4540-a400-bb2811c7e6c0	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaee-7a62-b46b-a0cfb832b36d	8be34bbd-733b-4a75-8bc0-d15b19207baa	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaee-7a62-b46b-a0cfb832b36d	48ce7b10-9f1a-4faf-bf12-450d1bf98d2c	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	15702cb6-70fd-4cb7-9b17-9f35bc6b8f38	BODY	f	f	2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	6a2da727-2268-4f2e-97f4-58f2bd612176	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	46c073a1-2510-4341-9b7a-d0dd2277ee28	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	9d58a62c-b5d8-4eba-8ef5-503a2a32308f	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	1164f83e-6058-49f3-b5b6-79ccb0405d25	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	ae9b7f4c-e4e3-4162-b303-1634e9fe1d06	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	3ec0b0e8-6362-40b9-a655-2ce4b64773e7	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	5c2c5194-4cf7-4ef7-a1bc-278ed9c7b58d	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	bf85d66c-e409-4c09-918e-31cb3edeea04	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	d2b1d1c2-26cc-4796-9e3b-53da138f6a0b	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	1917b776-b615-46a0-85f4-341ef159d2bb	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf4-7edb-81b9-282313c635d6	3be046f6-7c1a-43d2-865d-68346d129b25	BODY	f	f	39.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf4-7edb-81b9-282313c635d6	8f52d910-2fb7-491a-a358-43f51b63903a	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf4-7edb-81b9-282313c635d6	ac4dd542-599b-4166-9db7-79a28ff7ac18	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	9c386228-5dc6-44b2-8543-bf0e8d137aea	FRONT	t	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	c942ae2b-b935-40fe-9518-47d03b3cc83a	BODY	f	f	1	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	18bfb6dc-bfe5-4c17-8093-889ecb85ca25	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	ac598792-a74a-4e06-a7ae-851393212753	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafa-7f5e-9b91-9392b84cb84b	8f0a652f-1155-4a44-8a3e-13f802a9cae4	BODY	f	f	3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafa-7f5e-9b91-9392b84cb84b	b383ec22-f6a8-4441-8b38-72d504c86a3d	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafa-7f5e-9b91-9392b84cb84b	eb117291-e8ee-4e89-9934-b0e2590c0c0b	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	2eace631-00ba-47f7-ae44-815580276973	FRONT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	2b0b1b07-e7a9-4a54-a606-d02118646967	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	352b19b0-190d-426e-892f-24bdaef17592	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	fd501543-7fdb-4ef3-beed-41900abb58f4	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	6d620b3d-5c3c-4573-a180-08d883b2a1ea	FRONT	t	f	0	f	combine	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	eb22e7a1-dfc4-4c03-8885-d0857b10ac94	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	c21eaead-f47f-4e6f-abf9-475561b125ae	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb03-725e-a7ac-16ddedab3c01	37ba8736-323f-462f-ae11-54ec0410f01b	FRONT	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb03-725e-a7ac-16ddedab3c01	80683ed8-b092-494a-8fdd-3ae55c999120	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb05-765f-aa7d-dab58755008d	002d2f8d-0107-434f-a26e-02a99c22f4da	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb05-765f-aa7d-dab58755008d	1ad1de06-955c-4381-a8b9-93b478ae3278	FRONT	f	f	0	f	rockcutter	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb08-735e-97aa-af93f7f2e9dc	35371fd1-1674-47d3-8c38-dc9bb0be7f2f	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb08-735e-97aa-af93f7f2e9dc	08a5045d-d4f8-413b-b197-f1a991a45fff	FRONT	f	f	0	f	chainsaw	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0a-7c22-b52d-cb72caf6e6af	36f61225-21c3-4bdc-bf5f-5e222d4924b0	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0a-7c22-b52d-cb72caf6e6af	a93490bc-48be-4bab-8866-e146deec0729	REAR	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0a-7c22-b52d-cb72caf6e6af	73ba85ee-fb51-499b-8908-3157ee8ed697	BODY	f	f	1.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	00b66a7e-f1b6-4112-ad9c-31c0bd0b23d3	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	2d76cf17-574b-4889-aa80-54baac2a1555	LEFT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	23b5cab0-be6a-4410-b422-98af0f2899f1	RIGHT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	fbd353b4-abf5-4688-af73-c4367f8d0610	BODY	f	f	1.112	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	f1394e61-710f-4f53-a692-6f7058e7860f	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	eb7ae505-ee17-4e5a-ab0c-115ed49daef3	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	f8281908-c2ab-4a64-bb34-b0522f8fda67	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	1c17f02f-616d-439d-80ec-e6dbb2905b8f	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	a3a8b7d7-79da-4d51-8cf4-0ea7aecdcb3e	FRONTTURRET	f	f	0	f	srmlauncher(std,two-shot)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	c48fbfab-5d89-4641-8b00-1d74d216d636	BODY	f	f	0.225	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	43a27d85-3872-43de-810c-d716e3a217fc	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb12-74db-b53b-5eef739e6955	97f89fba-30cb-48af-909a-e15809cf57a7	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb12-74db-b53b-5eef739e6955	726b0d10-2afe-47b0-8ab1-a0adfc55c5e8	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb12-74db-b53b-5eef739e6955	6c4dc6e5-6f33-4db0-9547-fa2d772c7c13	BODY	f	f	0	f	svchassismod[snowmobile]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	4999cee5-6655-4981-b354-79fbea824158	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	7c6b5761-c826-4177-af23-e39d3b0552e7	BODY	f	f	9.98	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	5d643e40-8540-49ca-9292-bafc64bb6179	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	4f97ae6a-e2d2-4092-bfaf-3ee194f76d57	BODY	f	f	5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	b9af9070-cab9-4295-a77e-73fce4a55797	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	11dff752-5e2b-47b2-b9d8-dac55b4f6d49	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	f0b301fa-ed7d-44cb-8b9b-e1c6471208c4	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	8601a034-8102-4663-bddf-85a2ecb294f0	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	c29fb306-12c3-438f-b4a8-078bfd13bcfb	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	d08c7dc8-9398-4e8e-a744-45d83dd56ab7	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	10d0c924-1dea-4ccc-9d38-0b525f28504e	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	1bb3af0f-546a-4152-9695-6e1fb087ac36	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	6b36af11-9d71-4c04-8fcb-4882b6186dfa	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	a4747f3b-252f-4db0-9e48-0f61ca54291e	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	90c9c1cf-b1e7-445f-9a5e-2f3e39f7a13f	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb19-70e7-944f-06e94c2fb2b5	06fcb29b-bc5f-4d4e-a366-94aa46ea673c	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb19-70e7-944f-06e94c2fb2b5	e292127d-18fa-4734-96ac-a5de21258874	FRONTTURRET	f	f	0	f	ersmalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb19-70e7-944f-06e94c2fb2b5	a45d50c0-6d34-4449-adda-2755724e7a9c	BODY	f	f	3	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	689afae4-2000-4e1d-8a3a-e0a4be21fdde	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	d36f9a49-c03b-4e12-ab6b-b03e2931331d	LEFT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	a59ab911-5e51-480e-8de2-f29276c471e2	RIGHT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	f7488131-65ea-40f0-a543-7ed2ba6065f3	BODY	f	f	1.054	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	4a55368d-ca90-47d8-a60c-7cc9dced2890	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	80084591-b1ae-452d-b308-c9a4088efbe4	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	10108276-1db1-48c4-8eb9-c899af2136a4	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	3692e22f-9926-4caa-967b-779d643c397f	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	dfaf41ff-b824-4689-8ad4-8c2ea8aa0a9e	BODY	f	f	0.225	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	b20312d8-cf75-470a-b05e-3c3e803a687b	FRONTTURRET	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	70f9cc18-fd6d-4a72-bf0f-b2bfb5a31d16	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	544778fa-55e4-4189-8248-4dd46f41b3cd	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	c0814723-36ed-4e1d-8cf2-8593714a70eb	BODY	f	f	0.957	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	a437cc37-7ce0-49b5-ad00-c469723a9b39	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	72956107-7a25-493c-8272-87e5db795907	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	466b8c12-aa97-4ba9-aa52-4b210921a08e	BODY	f	f	0.225	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	0fbdadf9-ba2d-41ef-afc9-7bcbb33d7579	FRONTTURRET	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	516ac4f8-a947-4cba-b512-2af0c9038a3f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	900d543c-66c6-48c7-bc98-dc33f67bab0d	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	d5561dee-03bb-4657-a224-42347bbf04fd	BODY	f	f	0.417	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	e3520c0d-080b-4e1b-9fe4-d3cb3f1e6fd0	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	f1720656-a96f-4cc9-b3b2-b8952aa1566f	FRONTTURRET	f	f	0	f	machinegun(semi-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	f8deb6b5-ac83-4419-b8df-4a212a0b425a	FRONTTURRET	f	f	0	f	recoillessrifle(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	7b1e1be2-5377-4fea-869d-b2283140a6eb	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	b0c70ad7-24a3-46ca-96aa-a468ec7f5580	BODY	f	f	0.225	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	e30fe0fe-4230-4b10-b1a0-7d6206773ad8	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	25a6ac9d-47f9-4b44-a3d5-3f39eb605e39	BODY	f	f	21.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	270ad289-0750-4a27-88cd-cc2008423d6e	FRONT	f	f	0	f	combine	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	e5f36221-c87a-45ab-b7ff-ea9c7ff293b5	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	8cd60428-4c80-433d-a160-9afd39237e18	BODY	f	f	10.44	f	refrigeratedcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	1df6ef3b-c31a-40bc-ac5c-cc61cd470bd5	BODY	f	f	21	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	57c56533-8cca-4222-8c1a-2d5c5dfd2b53	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb2c-7dd0-b55a-dbea0e342200	eb946abf-6b82-4358-9b36-6bf553d6dbab	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb2c-7dd0-b55a-dbea0e342200	bb573dc7-5a7f-4f12-bb19-6cb8bc2b487a	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb2c-7dd0-b55a-dbea0e342200	02d2c055-cd54-4224-b06e-44169cea2751	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	5
019f583e-eb2c-7dd0-b55a-dbea0e342200	7bb293bb-2419-425b-bedb-af2c705edc3b	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	366cd81e-7cd1-40db-8709-616cc599957b	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	0226fa7a-040f-4847-92e9-4877d2393d9b	BODY	f	f	1	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	11bca06d-fd18-41a0-8b31-27dd3c532469	LEFT	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	d7c1a63d-2a77-44f9-b3c1-46faea1a3784	RIGHT	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	a47a0ebf-1448-47a2-ae33-1d697d0cb3aa	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	3496a123-93c6-4db7-a986-756f6cd7e6e1	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	3871d3ff-69ad-4b22-be08-70123b95085c	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	e27a7d29-ee5a-4dea-b881-2bf585fc60ff	REAR	f	f	0	f	trailerhitch	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	a4c63dbd-85f8-4b93-b342-70e412a1da50	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	c54bcfe4-9b6b-4bbc-a7c8-ebb79c3242d8	BODY	f	f	7	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	c5e1bc49-d8bd-496c-8118-19a33cc3de2f	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	f13265a2-4830-49d8-bdce-ce41e48fb835	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	a77622c3-51a8-46d1-ae56-3d74edb57252	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb36-7f04-b382-7da6a3064956	87959b10-c434-4dc4-88c3-31502ac4326b	BODY	f	f	3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb36-7f04-b382-7da6a3064956	b9f8bec5-809e-4d20-9b78-9b717ea4452e	BODY	f	f	15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb38-7c8e-9913-22a6dd885e82	6828befd-8eb5-45ee-9c41-a375cb7f0a4f	BODY	f	f	5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb38-7c8e-9913-22a6dd885e82	6065099f-57af-4574-a7a1-95727ada40f6	BODY	f	f	7.5	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	cc72170d-7459-4754-a5ed-bc69a52ecb17	BODY	f	f	0.1	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	86f4f199-d4be-4c05-986f-02ac60bac3f9	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	ee4e03d9-f5b1-4d33-8362-cd224dd4c8d3	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	7e305e06-dc54-43d0-82e3-39bb919237da	BODY	f	f	0	f	fluidsuctionsystem(standard)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	ff571467-1c77-440a-9330-894e5728c190	BODY	f	f	0.9	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	9971c622-21dc-4e9f-8934-69598f7e51a3	BODY	f	f	1.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	ec55e112-2247-46f1-a857-20519ea8cb51	BODY	f	f	10	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	b476fe18-194f-4978-9677-e1e475ed992d	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	0619544b-d2d5-41fb-b423-d1528e190f36	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	28cd8165-ab08-4002-be91-4174335fcf9b	BODY	f	f	0.55	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	f21a6403-106c-474b-b637-c19472ad284c	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	b1a830d9-59d0-48f2-9b0f-6cbee2766070	BODY	f	f	0.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	0685f227-a927-4b44-b869-a8a03eb50106	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	a0a0685c-5ac5-4df1-83d7-f51ff3a339c1	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	9aec5791-3930-4df0-a979-747b7567e264	BODY	f	f	2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	adfbfcd4-e062-4294-8e1f-fed98a0bd049	BODY	f	f	4	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	47c71648-5867-4734-96e4-20f8045c9a06	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	6e0b7f66-ad86-48f5-a243-5aed8bb998fb	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	d79faeb0-b123-4b17-a2c5-d56b3847853f	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	0e8f289b-a563-41f6-bbd6-6d59ea2048ed	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	e16dfe3d-53c3-4049-bd96-3b35662e2dc6	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	d3962dfd-6499-421c-a7b4-dece6009a518	FRONT	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	5e33b73d-c7ab-4c25-bcda-4033206d0243	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	6bf0b7ed-5970-4a9a-9a52-d8abf3a9aa30	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	13eb19cd-b4c4-4dbc-9bb7-cc695d73b8a9	BODY	f	f	11.393	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	68138e7e-cb9d-4864-877d-84878f192627	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	a7f78abb-3e7c-48c8-b59d-733b6d46857e	LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	b98794c6-a582-4798-b168-45a6cf949d70	RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	7fa89369-69c2-4b48-a3a3-323e2ac1907a	BODY	f	f	0.034	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	82cc1507-9658-43fc-b549-9bb65c06ff90	BODY	f	f	0.05	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	60f58342-1129-4f85-a974-c305edd88c0f	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	6bdec1bf-73e4-4949-b28c-e1ce40555885	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	8fa9c757-1af9-44dc-b958-61dc81478fc9	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	b17f562f-134c-41ec-8082-290aa20d78e9	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	d7867879-1fdd-4f94-86e6-038a8d59a19f	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	668744c3-6859-4ce3-9b19-3058270af202	BODY	f	f	0.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	4db88fd9-3b6c-42a7-bf0c-08b93ecb8440	BODY	f	f	1.2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	6e4e2286-0afc-4d31-92e3-329d3cd346b6	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	5490eb1b-d4b7-48e1-b5d6-9f04fdea0741	FRONT	f	f	0	f	satelliteimager(high-resolutionimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	8b3c8049-fa24-4c59-82fd-dc3ccc4e7ba0	FRONT	f	f	0	f	satelliteimager(infraredimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	cc1dfcca-33ac-41d1-9235-fa4e3ad34743	BODY	f	f	0.3	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb52-7363-9406-1098aa6d4964	0fe29aad-25d7-402d-9cbd-9980380ea5f8	BODY	f	f	8.55	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb52-7363-9406-1098aa6d4964	d98d9cfb-4153-42e7-afb4-84c62c1a2bcd	BODY	f	f	0.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb52-7363-9406-1098aa6d4964	0086254d-b1e3-419a-8b70-3b39079a0afe	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb55-7c2a-8bff-ac2a239a9f9d	59ae1fdf-e1e0-461d-b4d7-7a3df010c8fd	BODY	f	f	12.55	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb55-7c2a-8bff-ac2a239a9f9d	1fe42b98-0778-46c4-8aef-28aae5eb087d	BODY	f	f	0.45	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	a05a4d0f-d8e6-4ed1-86b5-ef91e030cd88	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	35503c42-cae8-4279-ab74-183baea82d09	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	4040fe3c-0f82-482e-95c3-e32e67fdc3a8	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	8350bb87-d0fb-412d-90d3-91fb555fdda2	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	9da687c9-7162-4eee-95fe-4f0de2f6dab6	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	2a78a748-f00b-4119-9d15-5d29835f75e5	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	f3d9f0dc-84ca-4e3b-a140-16b0b5ba8f4f	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	1e83c260-92c7-497b-8f85-a3277aa29242	BODY	f	f	1.5	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	6e053e3f-7117-4d6a-a419-833d181fb910	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5b-7ae1-8f12-cd59cc2cccda	623d70fc-afe3-4a77-a03e-4117fe9244ee	BODY	f	f	0.052	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5b-7ae1-8f12-cd59cc2cccda	9b1f11e8-05a9-4e1e-8aff-857c4c26f0de	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5b-7ae1-8f12-cd59cc2cccda	1d72fa6a-4332-4480-8552-5590ce91d035	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5d-7850-8b3f-6c542e769a19	474c7668-cb9c-47ea-affb-893f94b9ac1a	BODY	f	f	0.21	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5d-7850-8b3f-6c542e769a19	4327212c-86f1-47b1-bb77-0a400830f116	BODY	f	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	f1381f83-18f0-4b86-9ac5-ea10430eaa82	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	7ac681e7-0ec8-4eb3-8ba5-a2e32149b6e1	FRONTTURRET	f	f	0	f	anti-missilesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	0dc84aca-1de9-4b03-90f7-9bdb1ff6f721	BODY	f	f	0	f	anti-missilesystemammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	e105f1a2-c0cd-4ae2-a08c-f0bcd8543197	BODY	f	f	3	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	07a63ac1-4e3c-4425-888f-1ba859a1bbe6	FRONTTURRET	f	f	0	f	smallpulselaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	8f0a33e6-3f62-44f3-a9dc-0d36b6b6eb8f	FRONTTURRET	f	f	0	f	smallpulselaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	b498093f-4dd2-428e-9a6d-612c0961db32	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	9eae8d02-6d6e-4f00-a262-25a785f27ca3	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	1f7a7191-fa81-42eb-a22d-169eb1b25866	BODY	f	f	4	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	18b38a40-69c6-4b5c-a166-f8275ae582fc	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	a54682a0-94a4-4e3b-9364-aa3dba4e22ce	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	bf847e62-849d-4b77-9a9e-89fcb6ae0fb6	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	2e3960e9-f1fe-44f7-a9a5-68505f2b4dc2	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	5dfa4d12-44bf-4013-962a-4c53660c2f76	FRONT	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	e300af13-4e52-4f49-8755-8936057e35d2	REAR	f	f	50	f	cargo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	9f89659f-db3f-421e-8275-bd9631428b8d	REAR	f	t	0	f	dumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	d647e121-9408-40a1-be2e-9994669b9d2e	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	d7c9c1d8-3471-48d2-8d75-ecb116b504e5	BODY	f	f	1.617	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	4fabb5fb-31fb-4901-986b-d6aa9956361d	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	5ff6629f-c032-494d-b39d-a773f4fafb67	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	ce2e502c-ba6b-4e5c-af7c-b8e4f98fe0f7	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	faececa2-915e-47d3-885f-b54472ddbbd4	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	e2e0ebec-56a5-4326-830a-bc3010082172	BODY	f	f	0.3	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	2669d5ce-2d6d-4ba0-9bcc-6d403d2352d2	BODY	f	f	0.739	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	a54eb60a-9940-4a60-9459-23bebcbf0360	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	1a0eae59-d638-4a63-a082-42edf4bc5236	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	ae80e984-e04f-4127-9302-b003102942bd	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	e6ab05b5-f380-4ff9-b89e-d5f2e3680974	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	3bebacb1-21ea-4c65-9ce4-26a845527416	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	de1e54f0-3267-4bcc-aad4-ef4b6cd6c6bd	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	08eee015-f562-4b42-a3d1-6738ba66b190	BODY	f	f	0.225	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	57efae3e-e0aa-414f-83c9-63d0a688ec9f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	f61fbb3b-2b59-4e03-a32f-c11ea419af47	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	44b36ba5-c6f0-45f1-ae30-98f05b0d00d1	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	ed6cfc31-513f-48d1-a906-03978f65a4a6	BODY	f	f	12.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	c7d39a83-9d61-4bcd-b884-50ef6f17c73b	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	48480355-d74b-440b-b184-5d8f6c5e655e	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	a2fe3d46-8e1d-47f6-a285-1cda7ed5c2f6	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	14c8a5c1-aed8-452c-a1b9-ae1e3eb49899	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb71-7be5-8895-b1a314f2b79b	0537c473-d47e-43d1-8a97-e9dec9351e03	BODY	f	f	0.021	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb71-7be5-8895-b1a314f2b79b	6ae7a979-b687-4e50-92f2-547b58be26a9	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb71-7be5-8895-b1a314f2b79b	9d5f24da-91b8-42be-a378-f13164685207	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb74-74ff-b99b-0639ffdd1412	a3ea3dd9-fa2a-4eb0-8001-bc745b55fb2e	BODY	f	f	0.198	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb74-74ff-b99b-0639ffdd1412	179be332-0d2e-419b-a2a9-82c0e8ae33d8	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb74-74ff-b99b-0639ffdd1412	1bf1e38d-bbf3-48c9-ba61-ddbccfeb22fb	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	d7ed5f83-4129-4ba3-81f9-b7aeddece3d7	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	49382391-5475-4059-98d9-e934ae3a12c5	BODY	f	f	1.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	d9c4079b-8aa0-49e4-88ad-3da42bf98d90	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	02c65659-3e73-4eac-8ec5-e910db0f8a53	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	b63009ff-47cc-48ec-ae4a-07866e7a8dd7	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	110e2c7d-d72f-4a57-8f9a-920564d7c7a5	FRONT	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	093d9818-fa90-41ae-a1e8-dcd60454d333	REAR	f	f	20	f	cargo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	91c99330-f0a2-4182-a252-366bf77f73b3	REAR	f	t	0	f	dumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	bb411408-f082-40c6-b03c-61579f6e82fa	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7a-751a-8bb2-1e31e1941b58	68ad008c-5254-40b6-930b-af03e8ab87d8	BODY	f	f	0.4	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7a-751a-8bb2-1e31e1941b58	72392a41-10ff-4ea0-af10-026f1fae4dde	BODY	f	f	0.6	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7d-7a0e-8c54-ca0a6f56b117	83aef553-7714-4d3e-ac1b-36ebb92593d5	BODY	f	f	0.025	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7d-7a0e-8c54-ca0a6f56b117	c033fed8-b9e6-4940-885e-0c3a480c0660	BODY	f	f	0.025	f	pillionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7d-7a0e-8c54-ca0a6f56b117	69664bf1-7b4a-419b-96cf-af9a0f298367	BODY	f	f	0	f	svchassismod[monocycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	6f8938f4-b242-4e04-bb8d-c11522ce92ca	BODY	f	f	1.383	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	13159f03-20c8-4dd1-95a6-b17bffb28f93	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	4ee749a9-c3f3-4525-bcf2-f25f5b79cc6e	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	c853f39f-3e99-40b0-bb22-3c144d1e6436	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	d738a912-8540-4f98-8de1-7675c4fd24ee	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	a8a64b89-5888-4c92-bff1-3e541f7d1411	BODY	f	f	0.3	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	56c24750-f1bf-414e-b63d-896b9184ed0f	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	c0e16d2e-53bb-4a72-b178-6f99a01da275	BODY	f	f	17	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	f8fadd85-d4dc-425d-b04d-930f2e51fe91	BODY	f	f	21	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	a005a144-533d-41ce-9331-d58779a8ad8f	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	70e481a3-3fe9-4e06-85a8-8682e126b78e	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	cf940b8e-4c17-40f2-9153-e4239a9ca3b7	BODY	f	f	21.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	f26e7f0e-b6f9-4cb0-b091-138fcb103ff0	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	577bae39-ae02-416d-bf39-05ee7b40a6c9	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	59b8ddfa-e398-4a35-9517-5d09c9e8f90a	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb87-7c93-89bf-8b7de4a95ca8	8923419a-71c9-4b9c-b336-ef5f55b90e74	BODY	f	f	0.1	f	ejectionseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb87-7c93-89bf-8b7de4a95ca8	72c090b4-b749-4e87-a6da-28f923a6da9c	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	a8ed6a53-c630-4354-8445-0c7cd1ac76b1	BODY	f	f	4	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	01dc39fd-117c-4743-af85-0f0478ee6245	LEFT	f	f	0	f	ladder	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	93d5ae02-b144-4299-913b-436e54ee7dd9	RIGHT	f	f	0	f	ladder	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	ad4cfb51-e45e-4929-a651-c99b1ad3c163	BODY	f	f	8.071	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	b92058a2-ca67-4efe-bd99-474223b2990c	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	016c9054-8c77-43a6-88aa-fcfad727f0a7	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	e6f41432-eec9-4048-acc5-f300eea2e53e	LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	19d7752c-4f8e-4777-9962-8c5554f05e27	RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	d4f1ab39-78df-4dc0-b51f-88d38f5b2b5c	BODY	f	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	db54c1b4-b024-472e-a6f8-0e257c66f258	BODY	f	f	0.136	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	f7671833-ba1b-4ace-b637-e1de0f88856f	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	0677c00c-e1b3-49f0-a003-b2ad49bc41bf	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	a222215f-528c-49f9-acd7-5c9f7d5ef99d	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	3cde4d01-1afa-4c9e-9b9e-8d476a1ea8c8	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	a5620472-fc68-4a81-ab46-0e51e0f53d49	BODY	f	f	0.525	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	ae766f11-6160-4c98-9e38-9f036774e9f9	BODY	f	f	0.128	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	6f31be06-ce07-4154-904b-57ed2e19a1ce	RIGHT	f	f	0	f	ladder	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	d810939d-cea4-4704-8f72-77f09e0d6fba	RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	0cc22777-a32f-4b53-8d8d-f429be9b1aa2	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	bc4f89f0-4751-4933-9902-9c8724d75d4e	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	80ab5dd6-e57c-4eaa-89be-30395db70add	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	c64704d7-cf29-4638-8e54-b98459961025	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	99ee189f-7c85-4b14-9774-b52e241bb8b2	BODY	f	f	0.3	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	5ea0c4ff-62f1-4dd0-8044-f20dc7836b44	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	3c02b94a-4a99-44fc-880c-12dab4b2262c	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	6ae8d75c-e390-4275-8be1-fc88b763b7d8	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb90-7b4d-bfac-cb63d60e73fa	f8f8dfef-4a86-4bf0-88e7-b57cfe2ce1ba	BODY	f	f	0.019	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb90-7b4d-bfac-cb63d60e73fa	564785f9-398b-46b4-ba58-12d47b198511	BODY	f	f	0.15	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb90-7b4d-bfac-cb63d60e73fa	33e54ead-74b1-44ab-a824-af155e3295b0	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb92-75af-8aec-4c4ff2992fd9	47779478-3448-4027-a712-bf63be023097	BODY	f	f	30.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb92-75af-8aec-4c4ff2992fd9	eb4da57e-4148-4266-96b0-18a745efcde6	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	f9a9f0c7-6ca8-4c9f-acc3-0546959e1cd3	BODY	f	f	29	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	964184b9-92d7-4b05-b134-117570ba9044	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	385f62f0-62aa-40e0-a378-c47a714eb893	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	09e67e30-5e26-4f40-835d-c3d4e0f80f40	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	a320ad9b-6b9b-4ff5-bf1d-c4f3dfc4bf78	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	0a0fd00b-00c2-456a-98fb-aab552d41768	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	f1c97182-0b63-420d-bbe8-8d973df0317f	BODY	f	f	16.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	b912383f-92f8-42a8-8073-44593336b58e	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	a32f7e45-4e31-49ce-83fd-216bfdf8f2ac	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	695329a6-3efa-46b2-8763-8339856126cc	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	46db3b9a-e3d1-4a3d-adbd-8587bf4dc4d1	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	2fa5f93d-0dd8-4c2d-8852-0284c18286ee	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	8394c9db-e248-4afb-824c-b45bbb684042	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	bb954446-af74-4f8a-9df8-b841b314a219	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	eb04d815-8f14-4647-836f-b0712a2eb6f0	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	f51a3e54-7312-4b4a-9df5-29c9a518c9ff	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	d709fcb0-cb0a-4219-aa97-da600087a43d	BODY	f	f	8	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	32c2853c-9dd4-447d-a566-6a9077be4ea3	BODY	f	f	8.5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	207a961c-a32d-4a56-9c64-d4968c699cdd	LEFT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	f6f60966-be66-484a-a170-ac969df76637	RIGHT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	8ebe2ae0-fe43-4efd-98c3-4bd267769f4a	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	dac09f10-c25c-4b8b-9b99-3157f36b02f9	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	4d78cd85-884a-4a4b-bd18-a6809d2c79d9	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	6b2c7895-98e2-442b-b216-69b3c96f53ab	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	a4539976-50df-41d9-bda4-647ebc420045	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	ab725e5e-e397-4454-af4d-2c137a332ffb	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9b-7ae6-84c7-e2da71753968	3614556a-eb8d-4b8d-af1f-c769670a0a2a	BODY	f	f	123.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9b-7ae6-84c7-e2da71753968	3bf5ff5d-ca68-4e14-b731-d1076c74aa1b	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	fe04c222-3b16-42a5-b438-a338f27c0abc	BODY	f	f	0.019	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	7eb8824a-4daa-41fe-8dcf-18a29b33e3fb	BODY	f	f	0.075	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	f06cc6af-a179-4666-9ce0-4c7d19b2fb02	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	abbfd119-329a-4cbe-89b5-f8c30dc0b1e1	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	9115f078-fa69-45a8-acc7-d2a2d75dd2e9	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	d21c89fd-1262-4b38-870f-451732cd37ef	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	30df0871-3144-4978-ae65-2c0a6c479d9e	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	2f03482f-169f-45c9-a62c-b0a88e36db33	BODY	f	f	108	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	484b24b7-01a0-41e8-830b-e388fa4efe2e	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	bdb91466-c28a-44de-949e-b72d5dc52371	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	47876710-413d-49a9-8992-f6a9b2c78ef3	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	d9d6d74e-0bb1-4d09-aa95-aeb9c49329de	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	b36b59f9-0f73-4165-8648-3e4c970be7b9	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	054e7adb-545e-4cb5-b95f-39b6bb14e13d	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	db3a0727-743e-44c8-807e-d46932e2a6e0	BODY	f	f	0	f	angelecmsuite	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	221bb7fa-a4a2-4601-bdae-7ad2c5958d27	FRONT	f	f	0	f	reconcamera	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	7503974c-bbf5-49c8-bcf8-6904de509dbf	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	8dd5d0c9-baaf-4957-a186-185d41d3568c	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	19d1ece6-aa66-4854-8e35-e8604fa50004	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	f2f56f5f-a723-43b6-be6a-876ea290456d	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	db09ac38-c3c1-470c-9cdc-93556ce0ffd4	BODY	f	f	81	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	0d55c7c5-1619-417e-bfe7-766e5b2adca5	REAR_LEFT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	973f3441-1be8-4ab4-b124-02d926d97854	REAR_LEFT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	0d4c133a-ec65-429c-9cc1-6b37f9647f53	REAR_RIGHT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	ad3c881e-361b-48ef-9952-aae4f9b1ff2f	REAR_RIGHT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	d640b7b8-5359-42f1-aa3e-16eb2315e982	BODY	f	f	8	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	d8536893-4497-48cc-a21d-27fde7d3bfa5	BODY	f	f	0.6	f	standardseating	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	5fdb9734-817b-45f7-a61a-f1d559df0459	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	5658d125-feba-4b57-bd53-c2522856f97f	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	34e37ce8-ed6c-4923-9d08-a90f34698cef	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	9a020992-c6d7-4532-9d57-3340aa73eac0	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	b46d6117-1380-4827-916a-9ef0d7de44be	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	cb8f1e5d-9296-4368-b8be-2b73a825c246	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	0c8d8aab-c75b-48b0-9f6f-d62a4d261b40	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	1374631e-dee9-463e-b0de-c3ba804786cb	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	4ea03024-99fe-49de-a530-2500710e53ff	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	80391b00-8b06-43ff-b663-ad03a6857af4	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	c26a0aab-99f0-46f4-8dee-c640fa0d4f29	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	cf43a083-aed2-4192-9acb-a03708f52df2	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	ddeaedd7-e3f7-443f-9382-471150821bd5	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	e4dca193-d20e-44e7-9e41-c5e1f1b42f90	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	ee71555c-8b9a-40f9-9992-9bb43c16b958	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	ffbc3193-5cbe-4a39-ad15-8e867217165b	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	87a8b12c-e4b2-44ac-b7e0-7c5bec676c92	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	eab9798a-e44f-4bda-aa7b-d66134358bc0	BODY	f	f	0	f	ammomml-5lrmartemis-capable	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	b0e6e6c6-616b-4286-b23c-c6299c993a92	BODY	f	f	0	f	ammomml-5srmartemis-capable	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	4effb6e0-a160-42f5-a0ff-617a43ae2444	BODY	f	f	20	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	24f2fc07-dcf9-45ff-aee7-a4269189be78	FRONTTURRET	f	f	0	f	hvac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	ad4d833d-1d49-4718-8a5b-61cd6774f2ca	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	c5527e1d-7102-4762-928e-df17b7981ba3	FRONTTURRET	f	f	0	f	mml5	INNER_SPHERE	ARTEMIS_IV	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	3de87419-3547-4758-ad24-151f7fa044b1	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	c74e354e-fe5f-461a-b95d-196aa9f26920	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	6d082231-5757-44c8-965f-db3760e711bd	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	e4914a66-4728-40f8-b36a-3db71227220f	FRONTTURRET	f	f	0	f	extendedlrm10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	9ad5b2b3-0a27-4732-b0d4-898a1e3aecef	BODY	f	f	0	f	extendedlrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	dafeab32-c990-42f6-946a-6563a08130e3	BODY	f	f	0	f	extendedlrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	8eaae3f8-d3cd-4d78-96ea-e2fdcb3dfdf1	BODY	f	f	18.2	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	3a2d30a1-06c3-4ab2-897d-ab169c2efedd	FRONTTURRET	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	5bb50d02-caee-4720-bbe9-97754908a755	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	d3be1b56-9d3d-4e2c-9347-94f19334de77	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	6c90e340-cc98-4ec5-a73b-7bc1ad1b0bc3	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	b6b58ae4-feb7-4a64-b5cc-615c92e1bc3b	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	c2af929e-f6b4-4070-a7ea-316e76fd20bc	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	60311bb4-147e-4655-8706-5f37cfdc6342	FRONTTURRET	f	f	0	f	extendedlrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	c756ec46-d3bc-419e-99b4-a1645a5d5553	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	de8524a5-ba44-446c-82ff-742bebe1917b	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	69bb388c-3a2d-4a92-a6ac-0808b937f232	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	8d920ff7-47d2-4598-ad15-b8e534c49b85	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	f1efa405-5786-422e-80ed-3f31a88a7648	BODY	f	f	17.4	f	refrigeratedcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	f5bccf97-731c-40a1-b8d2-1ac2dace3f92	FRONTTURRET	f	f	0	f	streaksrm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	98811a91-4dab-4cf8-95bf-3be7678be397	BODY	f	f	0	f	streaksrm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	1c554470-ad42-4861-a554-f87055e8e4ec	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	d50ad5b4-b07d-4295-b19c-7a0a25697d3a	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	9ab69a47-1eb1-42f8-8ebc-a73439278811	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	48e58d13-770d-4741-bda1-768d535a1c08	FRONTTURRET	f	f	0	f	hvac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	ee8655f1-9edf-4da0-bb02-31f8a4ce0735	BODY	f	f	0	f	hvac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	ffcecac6-91fd-4477-a178-94db0adc9011	BODY	f	f	0	f	hvac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	9e88a4cf-4b30-46ab-81ab-a9a36bca4628	BODY	f	f	16.6	f	livestockcargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	23f72f58-8310-42a1-a06c-17590bd30579	FRONTTURRET	f	f	0	f	rocketlauncher15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	9c583623-e134-48d3-b5e4-f0a0c7c97e0e	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	5ee592fc-a067-494c-8f6d-4961c0bafb74	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	68c573d5-ff74-4e03-9ce3-f7aef2bb7820	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	058aba2d-dae8-4ab1-8d27-f10eb8fcca32	BODY	f	f	4	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	8fb72a97-62d5-4047-b09c-52012dbeef3c	FRONTTURRET	f	f	0	f	extendedlrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	e6a663dd-7984-429a-a83f-bd1212841afc	FRONTTURRET	f	f	0	f	extendedlrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	5722a812-437c-477c-8674-10c416348f00	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	785ff495-a53c-4683-a147-558917016fc6	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	80b328c7-94ab-408b-89c6-69400e750453	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	bab3bebc-3bc8-4921-8941-646cc221db25	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	fb95ff9b-ed1c-4d4d-bdb4-c4eb56907751	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	1d732081-3edc-41d4-8eb0-7ce5a5396997	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	7b29b48f-01b5-4e18-9b9c-ccb68299e83e	FRONTTURRET	f	f	0	f	hvac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	b7470e55-0665-424b-b1ab-2c390b443780	FRONTTURRET	f	f	0	f	hvac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	accd7485-c07b-42f3-8030-abe3b881b126	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	e160fb9a-7164-4d1d-b6b3-6e38e4827c8c	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	f5316f8e-78e6-4179-8719-f5e2e485672a	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	3441ccfc-825f-4cca-bd6f-2eec996886ba	BODY	f	f	10	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	85b39737-0048-47c3-be55-64c228623f6d	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	42e91db1-4900-47eb-b060-5dae9fab07e1	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	b6037978-fb17-4d64-b00e-0180b83d420c	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	cf855593-0247-4f79-b3e4-d61a32e889a0	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	695d9d7a-563e-4ca3-ac21-d585a5699426	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	a6b02539-0a79-46c9-9905-b3f02244e24c	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	e50d650c-67b8-4cb3-806a-467d3f5e7b11	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	9032065e-65b1-4061-9b1f-911cd77a15eb	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	3bab58d9-f8c4-4be8-9e46-26852f1fc9cb	FRONT_LEFT	f	f	0	f	machinegunarray	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	778bdf19-8542-4f9d-a957-1a72410fa320	FRONT_RIGHT	f	f	0	f	machinegunarray	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	0c3a37ae-1da0-4d89-b02a-5d6767016137	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	4f6b2858-d2e5-4851-b2e9-62c0783e0bbf	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	80f685fb-1d0d-495e-960b-0766a988ac0b	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	aecf1774-6ba2-48a3-b439-1e9a1dbe7938	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	f454c44c-af4e-4063-8302-b9d3e1e24c34	FRONT_LEFT	f	f	0	f	vehicularsponsonturret	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	f2c4fd0c-1fa6-4515-9f2e-a89591b7c31b	FRONT_RIGHT	f	f	0	f	vehicularsponsonturret	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	94c78697-0143-4883-8c30-6c5f56f90bbf	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	74029ccd-2827-4657-abb1-aa5f36a63b8d	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	e5e0034f-7c9e-4d92-9ee7-c888ee17e144	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	a2c1cb17-1e66-4c02-89a2-f76aca157e6d	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	c0403e30-7aa7-4dc7-a6e1-0e23e2602638	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	2d1ec18b-db54-4055-a5d6-e8c88f383934	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	087b0037-5e3e-4711-a9ba-a79be33ae7b0	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	6910fe59-65de-41f6-8e00-8ac25f39123a	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	5287888c-11fa-4282-bc47-f714f6f0ccb3	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	544a3f78-26f2-49c2-ba8d-2cee58e4b24c	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	22eb3e3b-862e-41b7-a882-c8b8054b5865	BODY	f	f	1	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	266b718f-2e2d-4187-8c16-7ac3f2d37147	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	dffb6bf5-cbbc-4a02-88f2-1fcad18b3135	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	08721f72-8538-4b68-8ab1-aebeb83f2a0f	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	3cdeda8b-5453-4e9e-ac4d-f1b6b4e1736a	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	d507b3bb-a3eb-4f83-bc0c-d6d5b185c834	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	ac8f3dab-fd51-4680-8fa1-3d091930df0d	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	d3b7cf96-b840-47dc-ad36-c845f0ceaef2	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	4783e835-d30a-4b81-a815-6ec7edcd26b2	FRONTTURRET	f	f	0	f	lrm10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	74fc1d41-3ca1-4125-93dd-93ba6ab27828	BODY	f	f	0	f	lrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	57bb7a13-f40b-4330-b36b-28862dbb5668	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	206940bb-7a41-4efd-a2ae-5bf86625d92d	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	fd80ed4d-2172-4841-9743-1ca501963cc6	FRONTTURRET	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	2d00740a-86f9-4b3b-aca0-d15d91f72190	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	b56dc9ef-0c5a-4efa-9405-876c3e97c0fe	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	53dabad2-6af7-45af-9af4-0b894c88c9ed	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	56413b45-8dab-4478-bfa5-e508d308d85c	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	9fc6920b-11b3-40aa-a86d-f61e4422149e	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	76d65757-6f67-4f68-9f4d-ff2d21343091	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	d7a0cc78-2415-4965-b9b2-4103794d90cc	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	c766e8c7-1008-4f96-b31a-c5587eba8da4	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	249e64d5-ada6-4c8c-bf26-3978500e5d6f	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	ea2eb52a-df1d-4b36-b671-e4bd743d7d19	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	4d080634-22e0-4aa9-a73d-8ba820e37251	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	036ad24e-a325-4abf-8b98-a9e20004f4c0	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	e49b38a7-a0e5-407a-b202-81ee769aec54	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	221a566a-3627-411a-84e7-dbfd7f3f2760	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	2eefe047-06a0-4fab-9c98-55cdcca36d1e	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	c7e473c6-6827-42c0-a589-0f1bc8e525e1	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	d2aa1dc4-76e3-4fcb-9ffd-59d22fa0a820	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	20175e16-95f0-490c-9397-dd0a44c65b92	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	679411bf-710b-4f38-92d2-e776ac546f94	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	188dfabd-40c2-4281-a5df-4fd0903fea7e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	39e0b2e1-72bc-468e-be78-5130d848a4cf	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	258629a2-b174-4639-b418-320931a16ced	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	4fcade17-6164-433e-b22b-e9bf1d304307	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	71061956-ad80-4fdf-903b-3c6c2b783974	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	1e968a0f-2dfd-4d40-ab44-2a7e67ef702c	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	4c16a4a9-902c-48e6-8136-a6462b63bb58	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	a186b732-2a7f-47a0-a7ea-de1a0897d298	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	cfca8e56-e7e8-4eee-9a55-156aa64570b0	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	f94c9bd5-495b-4eb2-9fc2-76cf21cd949d	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	3198bd29-6548-4d94-977e-aac7cdf77699	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	355b811f-d974-47f4-8eb9-663ae21fa7f4	BODY	f	f	9	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	14c2cbb0-0930-46eb-ab1c-40c58e447015	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	b63dbbdb-1562-40f5-ae1f-7d887561342c	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	660fa08f-2257-45d6-9e89-790f74fa1441	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	f6a453a5-62a1-45ab-b3f3-a872c42aec44	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	0193c704-b713-4208-ba09-b93de2be9ac4	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	38c99800-9e8e-4f01-b1f4-5929285a129f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	2cc9238f-f126-4160-9f92-5889343cbfff	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	5ae44991-273e-44c3-be23-0ec8c5bcc368	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	7c2561f6-3921-4eb9-9764-0ce805e69914	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	8aca9073-bc29-4079-b44c-c7307897ef3f	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	a0d3e1ad-0ea9-41ca-9b98-d30424216a57	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	a274f8ec-454c-4dd4-b242-bc15e2a11254	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	c6eb649d-3442-41c9-8b07-428f3aed1115	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	cbf6e45d-aa3a-4b35-b615-5fa9f2208cf8	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	fcb2f059-e33f-4fe6-ba44-9b66bdc206ca	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	0439402f-1401-45f4-a2a2-faca0b5408f2	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	0ad848b3-bd70-4137-8aa3-392ec39b275e	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	43f473b2-c273-494b-9911-91c0f328dd06	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	65e121fe-bc7a-4e1a-995b-153955786e7d	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	7490d020-c804-4a9d-9b0f-c36e27a807c2	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	84c770ea-d453-459f-b48c-621681fd454c	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	cdc21262-162f-4220-8018-a54c038315ad	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	fd75b15f-1bef-49f7-9883-0d62c60a2066	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	ab2facfc-b777-4d1c-a670-c1a9e86f6ea4	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	a557336a-4e0d-4f0b-97a4-be1c1c7cd48c	BODY	f	f	6	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	85641acc-1415-49bf-bc68-7ac2854db29a	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	467bcebc-589e-4565-9a62-04752933ca56	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	6470c982-e653-49ff-9b1c-3185c0e5d14e	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	3a77bcb4-296e-4018-aade-f4236b9fefa4	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	61dcb326-792a-482b-af7a-fccb4e1c2ecf	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	a156dd36-f565-4339-872a-0fe335c9d1d1	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	d0348c69-2074-42dc-8080-dee7c002290f	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	e490c285-bede-4182-be68-0a2efe386f91	BODY	f	f	2	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	fa1e4747-9355-4b1e-bdad-f1f60f944000	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	2
019f583e-ec37-7f5e-b29e-160141dfcb8d	b6ddec4b-b5cc-479c-83ee-7b76054e40c9	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	cd56e63d-956f-495e-a256-d856b9ba20b5	FRONT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	e40660dd-7942-4853-9860-27d429907df2	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	f8cc3e2a-3006-4e48-b01b-602226d7cb93	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	e45b4aab-123f-469d-b755-0dbefe9878d6	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	172d8189-ec62-4ddf-8666-3a5ae0d2fd1a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	5e0f44b1-f896-4476-a22f-d29ccd8aad8a	FRONTTURRET	f	f	0	f	largelaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	81ee9948-e246-44b8-be29-798407b99699	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	dd8c1602-c85c-4677-9e12-74f7a6b88444	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	f9f16762-4f7a-4c6b-af64-99a569545eed	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	fd9e2359-0052-4e78-964f-52199012bad4	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	11d3d560-1df4-4a03-b19d-ccaef3206578	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	2403448b-e00f-4132-aab9-1efc8e821b7a	BODY	f	f	3	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	9870c1dd-9fb0-4072-8687-43d6c3e732d2	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	c9754bdd-ee80-4f96-9e7a-61450d8dc6a5	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	f272adf3-90d9-4109-a41b-196c3d0be277	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	f84810f6-f61a-4add-b131-e7f8fed9a311	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	98cc0b0d-f5db-4e37-968e-a82fe58397f7	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	b9e699b2-d6fc-4fbd-8012-f6bbfd79b60f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	53f1f9cb-f765-4d88-aabe-3560f59e466f	BODY	f	f	3	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	c0544028-64a0-44e0-aa42-2aa8f9d634a0	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	3984c979-5335-4629-b509-6b25a7a78adf	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	3e1b080d-906a-481f-b0d6-81e7ac23053b	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	2509aeb4-3f4d-4db8-bf70-5436f480df4c	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	f4d99d7e-6658-4e44-8dc5-ae257ab81063	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	0ffbefc3-e853-4e6a-a515-0983f1db0885	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	d19ed123-d1ea-4a53-9c1f-d145be5727ac	BODY	f	f	9.5	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	0bb95661-bd43-4fb7-b17e-8ee2295c6ce8	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	cb779e6c-60b4-440d-8382-a961bdd57c91	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	ba5c4520-f9d2-46c6-9a66-456060aaed34	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	f7234530-3722-49a5-a5f5-0409e89a27a4	REAR	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	bf27828b-5424-418b-a9d7-1ff37bdf954d	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	40c2b9b5-d208-48da-a35d-57af06f214c6	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	ef74d194-4e98-4fd4-a59c-d9cb66b0a1ce	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	d34d10a1-138b-4719-bc0a-35109a6e3c2e	BODY	f	f	9	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	e983a5e2-5767-46b6-b0df-34c26ead4e81	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	f1024910-e1bb-4326-8d20-ddb4fa0ba030	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	37d79348-6589-41da-b84b-9a2d0b77f8a6	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	8e468284-0b92-4424-9081-f45b1d99c538	REAR	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	e1b37e03-5e37-46b4-8ae7-58a63f9579b6	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	abbc8992-386b-4c85-814a-36b690f291b6	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	222101cf-9fad-4ccb-825c-4d527431748c	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	0714c90d-b186-4106-8385-8f96a9d90b49	FRONT	f	f	0	f	primitiveprototypeautocannon/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	0825a652-4911-43fb-aaeb-008dfd7fbea9	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	42a4d8a5-d85d-44ae-9345-37b203205bb0	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	7331735d-dd77-48c7-bbf5-95321097b4d3	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	b26c62b7-3bea-402d-a9ab-3e7ff7032e9c	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	a22b3082-f8d7-44b3-9ab8-fda8782cbef3	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	b4a1e249-030c-40f5-bbb7-3e114aa71a8a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	35c9bd30-d0f2-4ee0-9c1b-c98824c96f84	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	5ab5b050-df49-4a16-a6eb-200f1c6b87f3	FRONT	f	f	0	f	sniper	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	67f76dbe-4e3a-45e1-b4b0-60b6c06fc4fb	BODY	f	f	0	f	sniperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	8edad1c8-a273-41a4-b305-ebc45b9a3dba	BODY	f	f	0	f	sniperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	fbf8104d-9250-4659-8b84-47c5c09a2b94	BODY	f	f	0	f	sniperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	60c63ec5-a4c6-42a1-a2aa-dfd9bd17ab19	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	47f01386-0b3d-4b67-94fc-5e8364a57ce3	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	824dcc7b-e814-4798-b131-421c6238e9ac	FRONT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	76aae52a-7f02-4fe9-902b-27a74410a7cf	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	89827c7e-6e7f-434a-b433-76992c873974	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	937ad16b-639f-458c-82b2-5b36f7e9847c	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	49caf69f-c4e9-473c-865d-c2705d5f5ea0	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	73847b02-ea24-4a71-a565-a6da91b691d7	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	bf0bc78c-5fb5-44a0-beae-716a34fa1355	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	6d484261-31da-4329-bb11-651ab22ce50a	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	58fd2e4e-6c4e-459c-8e6a-3c565e5db4b6	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4f-7522-895b-66f3e0e40f6e	f1558c0e-fe7c-48e5-978f-25dbc54ed95e	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4f-7522-895b-66f3e0e40f6e	ccc5d195-a802-46aa-8a97-800064f42119	BODY	f	f	3	f	infantrycompartment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4f-7522-895b-66f3e0e40f6e	b1ad030b-3ecb-454c-a0e2-f641c4860bf9	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	c00259ec-ed6d-4c06-bc2f-04c7db223753	BODY	f	f	20	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	b5135dec-faf6-4e74-bf58-76ecf95196f8	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	ffcaecf8-fead-4cbe-8013-cf38f71b41f1	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	f0fab5bc-792b-4701-b11e-b9b3dd73fabe	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	90d21358-7486-4d09-a6b6-042ef67ebb42	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	345e3315-0281-4d0c-8f82-f1a4d1ef6d1f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	3de5840c-7a7a-4f1f-90ff-a12de203428a	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	c96e04cc-9ac1-4044-9790-baed6d76e0c3	FRONT	f	f	0	f	thumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	6035b8a9-f0db-4ec8-901d-4f7065029365	BODY	f	f	0	f	thumperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	72f5b6ed-642b-4203-bdce-064855402409	BODY	f	f	0	f	thumperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	83d9bd8d-75af-4098-91f2-44127a80d794	BODY	f	f	0	f	thumperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec54-7008-ba53-94c900e2263f	a6b226f8-df61-4e30-8450-34b981c4dd8a	BODY	f	f	40	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec54-7008-ba53-94c900e2263f	2d0a09fd-84ee-4025-90b6-39cc26a70d8a	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec54-7008-ba53-94c900e2263f	aa9f039b-f8aa-4136-9363-7c53a83a572a	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	8ce8a6d1-6776-4f52-b49f-39b1fd3b66fa	BODY	f	f	24.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	93cae8e4-eae1-42a6-a96e-b8c8a8f2a8b0	FRONTTURRET	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	c4a90c59-5b95-429b-911d-3593554a6fec	FRONTTURRET	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	b18003fc-d1cc-4955-9f5c-4dbffb27cd57	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	7caf2fb0-76fe-4d0e-8633-cbcf1910c19e	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	5b70ee20-b14f-4e33-82fb-e61116cbce37	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	902c3a6d-c582-479c-a90a-f7444c6f0d81	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	010b71ed-983c-4995-8b0c-1bac0762a5eb	FRONTTURRET	f	f	0	f	mrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	0e68c4f8-94e9-49fc-99f9-c0582afa3054	FRONTTURRET	f	f	0	f	mrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	342534d1-612e-4d84-a5be-25019746778b	FRONTTURRET	f	f	0	f	mrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	17dca214-3d4b-402c-91ad-c1900bf9e168	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	3a4160bd-56e9-4271-8a42-164419926205	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	4663c36f-7dfa-4b3d-809d-29421d2bb2b5	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	8869a2a0-f4ef-41ce-aa52-a432a5ccdc7f	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	e640ca34-d67b-46e8-8474-d0bea43ac5a9	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	8afca370-9633-4d88-add4-24880dff1702	FRONT	f	f	0	f	bloodhoundactiveprobe	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	f5396084-e0d1-4755-af85-9f38ad574a11	BODY	f	f	2.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	f4e72aa8-1855-4bcf-86da-68b6ca5b9879	RIGHT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	d00e1d68-96d6-4535-9bb7-28ce5a028499	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	ab393995-a310-4a5e-b40c-15e5e08c3c5a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	d8819a92-aab6-4a83-9568-8368a145f9de	BODY	f	f	30	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	69403ea7-2c44-44a0-b430-0053a5d38ad0	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e79a6ff5-e312-4925-a913-87b50529838b	FRONTTURRET	f	f	0	f	ermediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	6ce48c23-0643-43d2-ad28-a4f6126c59fa	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	861a9421-ac8b-47c2-8efd-b9ae85d7bebd	BODY	f	f	10	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	b25c322d-e36d-4879-9acd-957c0f178a96	BODY	f	f	10	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e9a7e39c-d30d-4c5d-bd67-61792def7d87	BODY	f	f	10	f	firstclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	dc436942-4b69-4554-8b48-ade2bbfdcab0	FRONTTURRET	f	f	0	f	lrt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	5dfeb95f-33de-4cb5-80ae-336db04f4def	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	845d37ee-e7f4-4549-882b-5faff95b98f4	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	14529fed-17d7-490e-958d-725eade5b8ad	FRONT	f	f	0	f	lrt15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	9944bcef-72ca-4e2e-bba5-c8eebcf559ac	REAR	f	f	0	f	lrt15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	5eda42a7-c85f-483f-bf91-0b7f90d243de	BODY	f	f	0	f	lrt15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e16047f1-1d09-4846-ac11-aba1299aa71f	BODY	f	f	0	f	lrt15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e2cdf734-d907-4fb6-978e-8241a2d56c4a	BODY	f	f	0	f	lrt15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	612d40e3-0ece-4d42-bd5d-9452d83fbeda	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	1
019f583e-ec75-7cd8-8032-f2d83d9a0544	4c22c72f-1bac-4509-876a-20280f4bc795	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	576b9642-0dda-4fbf-9452-1a37c01fbb22	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	847145cb-d419-494c-80ae-ce3256dcbc4b	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	f88e985f-62e4-4181-9fc4-0eb0dd0fde7f	BODY	f	f	7	f	secondclassquarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	f8ad72b8-937f-432a-8102-7d0d9f201778	FRONT	f	f	0	f	srt4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	17b4ff6e-34f5-4564-a996-410bfcb6e8b2	FRONTTURRET	f	f	0	f	srt4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	7856233e-31c0-45a2-828d-0993290e2ee6	BODY	f	f	0	f	srt4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	ea52e64d-54de-48c7-8251-14ce9195cb76	BODY	f	f	0	f	srt4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	388ff600-9888-48bf-93c4-9c8159453711	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	9a3d7a04-3fcc-4796-971b-e1d58caff462	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	bdb04622-388e-4061-af70-8e045cf183d3	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	d837a01b-183d-4203-89ac-a7d4edf8a3c7	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	dd19f5dd-1e8e-4351-9f3b-f5645303d669	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	ec5611ef-fc88-4a48-9e5c-21c39c4f2883	BODY	f	f	5	f	steeragequarters	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e0c703b8-0c83-4f39-aa4f-a56c43a8549f	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	3e0309cc-b1b4-40e8-8a28-8cb099bac12c	BODY	f	f	0	f	boobytrap	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	b387e28b-5746-46ce-9b02-20f62745111b	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	c9b14741-2503-469a-8d6d-e6c3b94bc27c	FRONT	f	f	0	f	drone(remote)operatingsystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	179e0c19-9f24-4be3-89ef-7cf5d9b9da00	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	7fa9b15a-6e72-466e-a011-403b1b61bc74	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	9ed17338-1f75-4aa8-aaf1-01eee46ec531	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	a284a1aa-bb9a-44c2-929d-b7c5ff823777	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	a6e2457a-01b2-4cef-9be8-d953fa74ed13	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	af17205b-9def-4042-9e1f-caac8981a94e	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	b18e9ea6-610e-42b3-8b68-92f7d6fcb70a	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	d7879b53-f4fa-4745-bdb5-42301ac76007	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	e712abfb-a11e-4ab2-a975-9541279a967d	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	ad87ad84-13d2-46f5-8e7d-c98805dbf6fb	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	37324885-c00e-4f80-8e59-469db84c0cae	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	a2f21593-c5c7-401d-8f35-e5eb7f6bcdcc	BODY	f	f	6.46	f	liquidcargobay	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	79cabc69-afcb-4e0a-8024-c3540ae1945b	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	76b7501c-5366-447c-b62e-7d8f334e1dd8	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	a025cf26-1a73-4702-965b-78f01915d199	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	1012c1ca-319f-44a3-a5f4-e982fc11bcfb	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	6c354278-dea8-4add-950d-8fba4cb4d819	BODY	f	f	0.5	f	cargobay	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	22accaaa-59d1-4267-98bb-cf27b5e99844	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	7eaaff6b-023c-4be3-8ae9-2dd3be3f8839	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	9b7a80ca-79ed-41b2-a404-4340fccd4c1c	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	52944a81-c0fe-4d19-a02e-18017dd022a2	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
\.

CREATE TEMPORARY TABLE v3_22_new_item AS
SELECT i.*, u.id AS unit_id, e.id AS equipment_id
FROM v3_22_item i
JOIN v3_22_unit vu ON vu.megamek_uuid = i.megamek_uuid
JOIN unit u ON u.id = vu.id
JOIN equipment e ON e.name = i.name AND e.tech IS NOT DISTINCT FROM i.tech
WHERE NOT EXISTS (SELECT 1 FROM unit_equipment ue WHERE ue.id = i.id);

INSERT INTO unit_equipment (id, location, omni_pod, rear_facing, tonnage, turret_equipped, equipment_id, fire_control,
    jump_boost, drones, mash_theaters)
SELECT id, location, omni_pod, rear_facing, tonnage, turret_equipped, equipment_id, fire_control, jump_boost, drones,
    mash_theaters
FROM v3_22_new_item;

INSERT INTO unit_mech_equipment (unit_id, mech_equipment_id)
SELECT unit_id, id FROM v3_22_new_item;

-- 4.
COPY v3_22_slang (id, term, lookup, kind) FROM stdin;
4e94b194-03d6-46f2-a986-d1ffb9e7a52b	AC20p	ac20p	ALIAS
7e801fe4-508e-418a-bcac-075254dd7a56	AC20p Ammo	ac20pammo	ALIAS
939e7408-7ff9-4dbc-8801-6627eb2c30cd	Ammo AC/20 Primitive	ammoac20primitive	ALIAS
ce3b0b46-8a8c-4e3c-be3a-8ed6413f610f	AmphibiousChassis	amphibiouschassis	ALIAS
0b3b3d70-54cf-49ce-8cc4-43be9deef6c1	AmphibiousChassisMod	amphibiouschassismod	ALIAS
fddfa63c-4b32-44d9-b555-e91140e84a3e	Auto Cannon/20 Primitive	autocannon20primitive	ALIAS
fdd9ec17-a71d-4e22-ac00-c8fa816ba687	Autocannon/20 Primitive Ammo	autocannon20primitiveammo	ALIAS
cbd41c43-9d62-40d1-8602-1532bd787ed7	Autocannon (Bearhunter Superheavy)	autocannonbearhuntersuperheavy	ALIAS
635d325b-dd39-4536-8448-996e8544f7bb	Autocannon (Semi-Portable)	autocannonsemiportable	ALIAS
6bdce34e-7da7-4551-9059-30fb78863072	Auto Rifle	autorifle	ALIAS
a0cc9702-6570-4dbe-b121-fe08df23efd2	Auto-Rifle (Modern, Generic)	autoriflemoderngeneric	ALIAS
2aedbc47-c557-43fb-9aff-8b1d91fc534e	BAAutoGL	baautogl	ALIAS
af5d0a35-24cc-4569-9937-ca43b51cbd6c	BA Grenade Launcher	bagrenadelauncher	ALIAS
bd9157dc-172f-484c-9a5d-9616e1111793	BAHeavyGL	baheavygl	ALIAS
837edce5-b8c1-4178-bcbc-2d939a3a4fa0	BA Heavy Grenade Launcher	baheavygrenadelauncher	ALIAS
c46a15c1-7d2e-415d-8316-ae05424d4b90	BA Plasma Rifle	baplasmarifle	ALIAS
3aeb8db9-5d45-4768-b499-9f435a5abd09	BicycleChassisMod	bicyclechassismod	ALIAS
f382edca-47a3-49c3-ad96-16b9d9dd0f97	Bridge Layer (Heavy)	bridgelayerheavy	ALIAS
824fb3e8-3e8b-4922-8552-affc9e17c3b2	ConvertibleChassisMod	convertiblechassismod	ALIAS
c2e575e3-2235-48b3-bac8-e1b1ff4e52e9	DuneBuggyChassisMod	dunebuggychassismod	ALIAS
8ed69f0d-7c4a-4e28-844d-6b9dae44c0d0	Field Kitchen	fieldkitchen	ALIAS
f619431e-f88f-48e8-a8f3-03660296ccf1	Fluid Suction System	fluidsuctionsystem	ALIAS
294f7f94-142b-4b99-a284-237a478e578f	Fluid Suction System (Standard)	fluidsuctionsystemstandard	ALIAS
7d2c3cc2-2588-4240-b738-09e96d39c0f0	Gauss Rifle, Light (King David)	gaussriflelightkingdavid	ALIAS
940af41a-5a76-4567-8d77-c7e5c7acd057	Grenade Launcher (Auto)	grenadelauncherauto	ALIAS
8e006c56-6b0c-4490-8cd2-08789b0f3fb5	Grenade Launcher (Heavy)	grenadelauncherheavy	ALIAS
79c95ade-79e0-4396-a53f-026b5a1f3605	Heavy BA Grenade Launcher	heavybagrenadelauncher	ALIAS
dc0519a4-209c-4161-b723-48aa3d7b445f	HeavyBridgeLayer	heavybridgelayer	ALIAS
0e1caa6b-8a0a-42e5-be96-c7a5040a1eb4	HHSearchlight	hhsearchlight	ALIAS
b869ca98-f562-4e6e-a881-df2593552fbc	HighResImager	highresimager	ALIAS
92748e32-242f-4652-8e99-93f9f8146954	HydroFoilChassisMod	hydrofoilchassismod	ALIAS
a64c66f0-b916-47d0-aff6-8091e66d9b68	Infantry2ShotSRM	infantry2shotsrm	ALIAS
41df8fe7-2b72-407b-84d7-2be470779631	InfantryAssaultRifle	infantryassaultrifle	ALIAS
b482b855-8490-4ea1-8215-aba21da017a5	InfantryAutoGL	infantryautogl	ALIAS
16a6d82d-9afd-4d67-9db7-fecc9ef075c4	Infantry Auto Grenade Launcher	infantryautogrenadelauncher	ALIAS
88e8785e-6358-4dbb-ad46-625e4137eb0b	Infantry Automatic Rifle	infantryautomaticrifle	ALIAS
0533ee4e-1f15-4239-a98b-4c7d54dba495	Infantry Auto Rifle	infantryautorifle	ALIAS
b422caf0-bd5b-4912-a8fa-35d0021028f1	InfantryBearhunter	infantrybearhunter	ALIAS
90e3faac-9da3-455a-bf56-7e70af2d1555	InfantryBearhunterAutocannon	infantrybearhunterautocannon	ALIAS
27566436-6617-475a-8c81-8238d105b5c8	Infantry Bearhunter Super-Heavy Autocannon	infantrybearhuntersuperheavyautocannon	ALIAS
e329f5e2-f678-4cd7-a191-f1940bcab365	Infantry Clan Mauser IIC	infantryclanmauseriic	ALIAS
628b4830-19c8-421f-826f-27c96a73bd70	InfantryClanMauserIICIAS	infantryclanmauseriicias	ALIAS
6830db9a-56c5-44b7-9deb-17c2426a25b7	Infantry Heavy Grenade Launcher	infantryheavygrenadelauncher	ALIAS
b17060a6-6408-4b36-958c-7f31d7bf9def	Infantry Heavy Laser	infantryheavylaser	ALIAS
9538f978-773b-4099-9a28-ad4b5eef97e1	Infantry Heavy Recoilless Rifle	infantryheavyrecoillessrifle	ALIAS
c0f8170e-d2e1-4a0a-bab9-b12c6040029c	InfantryHMG	infantryhmg	ALIAS
d263fbae-d7aa-42eb-bde1-3869343e6eaa	InfantryHRR	infantryhrr	ALIAS
8f959020-2e43-422d-a0c5-c52db7d09532	InfantryKingDavid	infantrykingdavid	ALIAS
f8eb5a36-2fb4-4f07-be1c-eb26f74fbd54	Infantry King David Light Gauss Rifle	infantrykingdavidlightgaussrifle	ALIAS
418dc69a-15bb-4566-af0c-df04a038de85	InfantryMediumLaser	infantrymediumlaser	ALIAS
d8112ec0-7bfa-4e00-b0cb-2a2f8f1566dc	Infantry MG Semi Portable	infantrymgsemiportable	ALIAS
e16aecee-6e7e-46a3-8046-20cc7a8b0758	InfantryMPPR	infantrymppr	ALIAS
91f966a4-4e15-438a-a508-92c97ff200c8	InfantryPlasmaPortable	infantryplasmaportable	ALIAS
7f3797f4-c623-421b-9652-e6665c278de3	InfantryPlasmaRifle	infantryplasmarifle	ALIAS
6ce95365-9229-4419-9fe5-59bbb417e407	InfantryPortableAutocannon	infantryportableautocannon	ALIAS
66320842-e69a-4c3b-ae3c-2c2acf2d2ebe	InfantrySemiMG	infantrysemimg	ALIAS
4cca1a07-df81-4807-a2a2-009d9f4b1cd3	Infantry Semi Portable Autocannon	infantrysemiportableautocannon	ALIAS
8b288588-6fa5-471f-a47f-193da295c681	Infantry Semi Portable Laser	infantrysemiportablelaser	ALIAS
bd79f88b-ba74-42a0-ab97-824a3ce4bb66	InfantrySmallLaser	infantrysmalllaser	ALIAS
eada8d04-f573-491c-9f58-e62da832966f	InfantrySRM	infantrysrm	ALIAS
50a603f9-9217-4ae6-b701-da279ea4e3c8	InfantrySRMLight	infantrysrmlight	ALIAS
82b94b74-5465-4c46-984b-181445993c75	InfantryStandardSRM	infantrystandardsrm	ALIAS
49e06b7c-fd0b-47f9-8971-2a0c04dbc23f	Infantry Support Laser	infantrysupportlaser	ALIAS
20557059-813d-4988-a907-05c6b8e33ac2	InfantrySupportMachineGun	infantrysupportmachinegun	ALIAS
a16e0097-486c-430e-acc1-35276cbc3005	InfantrySupportMG	infantrysupportmg	ALIAS
32542e92-4a72-40eb-af4c-e2ae38e453fa	Infantry TAG	infantrytag	ALIAS
6149fbd0-20ff-4c87-943a-b7692b1324b7	Infantry Two-Shot SRM Launcher	infantrytwoshotsrmlauncher	ALIAS
bbedaf85-101c-4f17-b3ce-5add53d5517d	InfantryWireGuidedMissileLauncher	infantrywireguidedmissilelauncher	ALIAS
50c346ca-f570-4736-ade3-28a005d7234a	InfraredImager	infraredimager	ALIAS
11c64eb3-f3b1-447a-b095-83b44de9bf2e	ISAC20p	isac20p	ALIAS
c248d4f6-e274-4d34-b58b-73b521d5e05b	ISAC20p Ammo	isac20pammo	ALIAS
e9d6731c-45b9-4e5c-976d-fcf2664fa388	IS Ammo AC/20 Primitive	isammoac20primitive	ALIAS
ba0f2ff4-27ea-405d-831f-198a2c8ad198	IS Auto Cannon/20 Primitive	isautocannon20primitive	ALIAS
c5b7929f-20b4-4453-8975-5e9e365a9a79	IS Autocannon/20 Primitive Ammo	isautocannon20primitiveammo	ALIAS
b83bbe65-4a17-470d-a09a-2fa9b9fd8214	ISBAAutoGL	isbaautogl	ALIAS
5e542629-5968-4fb7-906e-c2bf94bab4b0	IS BA Grenade Launcher	isbagrenadelauncher	ALIAS
c87b1087-b5db-4417-a588-a480e9f4a1b1	ISBAHeavyGL	isbaheavygl	ALIAS
77f088d0-c14b-4697-bf90-e458e7a58565	ISBAHeavyGrenadeLauncher	isbaheavygrenadelauncher	ALIAS
80b2100a-8de2-476c-a3c8-7aa68eb991e6	IS BA Plasma Rifle	isbaplasmarifle	ALIAS
0247db52-1663-4694-b2c2-a3ce0c3c15a8	ISHighResImager	ishighresimager	ALIAS
72c17743-7cb4-4ec1-ae03-c48fa775e6e1	ISInfraredImager	isinfraredimager	ALIAS
9b1f71dd-4731-4983-b005-dab490246775	ISSVDuneBuggy	issvdunebuggy	ALIAS
9f94a5d8-4e81-4f03-89a9-e2ac23b76bf3	ISSVDuneBuggyChassis	issvdunebuggychassis	ALIAS
7c0d3efa-7653-4c4a-a2b8-ce6bf543a2c3	Ladder	ladder	ALIAS
d0eb6b4d-3646-40e6-9466-bbfc22993f24	Ladder (100m)	ladder100m	ALIAS
240f6d79-5431-41b1-9052-6f928b35f4dc	Ladder (20m)	ladder20m	ALIAS
8b5d20b8-8b7b-4df6-aa61-fdce8ffe9b63	Ladder (40m)	ladder40m	ALIAS
0b9f6156-5d2b-4aac-ab29-aca125340aae	Ladder (60m)	ladder60m	ALIAS
a2da4ca0-a0d3-41c3-9ed7-52e807aa634c	Ladder (80m)	ladder80m	ALIAS
93885c2a-5566-40c4-b039-d1708588fb6d	Laser Rifle (Mauser IIC IAS)	laserriflemauseriicias	ALIAS
f6db5698-8676-4fda-927d-4f5d8d8a850b	Light SRM Launcher	lightsrmlauncher	ALIAS
b427bf17-856d-4e4a-a6b1-343e6474636b	Machine Gun (Semi-Portable)	machinegunsemiportable	ALIAS
228bf9b0-d522-4dce-80b8-e0bfdb08d3e4	Machine Gun (Support)	machinegunsupport	ALIAS
c4c6c5e5-7656-44e3-af67-86840dca5de2	Manipulator	manipulator	ALIAS
b3eda8c3-9a69-48e2-9abb-4ff5aa7bc968	Manipulator (Non-Mech/Non-BattleArmor)	manipulatornonmechnonbattlearmor	ALIAS
c92d9eb4-4907-4576-b205-06fa2132ca11	MonocycleChassisMod	monocyclechassismod	ALIAS
b6a03dd3-2966-4564-8325-e6eff2ab612b	OmniChassisMod	omnichassismod	ALIAS
ca11497e-2091-4b7b-9ef9-4e2c649624e9	Pintle Mount	pintlemount	ALIAS
6cecb67f-d01c-473a-995a-acae2f4f9c23	PintleTurret	pintleturret	ALIAS
b1fcd6d8-3831-4583-9c7d-6d34b1c2e22a	Plasma Rifle (Man-Portable)	plasmariflemanportable	ALIAS
0a9a41a9-1630-4664-803e-0f9e6c510d6a	Portable Plasma Rifle	portableplasmarifle	ALIAS
57c630d3-8054-422b-8754-262163139765	Primitive Prototype Autocannon/20	primitiveprototypeautocannon20	ALIAS
57169d50-a37f-42e8-b65f-75d991d9893d	Primitive Prototype Autocannon/20 Ammo	primitiveprototypeautocannon20ammo	ALIAS
18644613-5d8a-4429-9907-fd6631cdac96	Recoilless Rifle (Heavy)	recoillessrifleheavy	ALIAS
717e6fba-3bf2-49fa-a20e-abe9bbce20d9	Satellite Imager [High-Resolution (Hi-Res) Imager]	satelliteimagerhighresolutionhiresimager	ALIAS
361fa2e1-712a-4dfd-8724-1fbe3f1355ac	Satellite Imager (High-Resolution Imager)	satelliteimagerhighresolutionimager	ALIAS
e1ddfac2-c54a-4d84-ad13-595a5b001110	Satellite Imager (Infrared Imager)	satelliteimagerinfraredimager	ALIAS
756528fc-3661-4e66-960a-fd9a20ff83ea	Searchlight (Handheld)	searchlighthandheld	ALIAS
3a55ab08-338e-40a2-8457-192536a00310	SnowmobileChassis	snowmobilechassis	ALIAS
604256e7-e9aa-4d00-839b-742d7105dd34	SnowmobileChassisMod	snowmobilechassismod	ALIAS
b309f0b7-c564-4fa1-9c8f-dd3a06a0d58c	Sprayer (Vehicular)	sprayervehicular	ALIAS
c357f2b1-1633-4833-a2a4-3de1a321e1a8	SRM Launcher (Light)	srmlauncherlight	ALIAS
113324b7-baa3-4cfd-bd5c-9ccd59ac75d0	SRM Launcher (Std, Two-Shot)	srmlauncherstdtwoshot	ALIAS
3222782a-995c-415b-a830-52501605ec29	SubmersibleChassisMod	submersiblechassismod	ALIAS
32293a96-662c-4c77-9762-18c8a096c7fe	Support Laser	supportlaser	ALIAS
b6ac4f58-b9f9-4c03-82a5-c349ac7bac83	Support Laser (Heavy)	supportlaserheavy	ALIAS
d34987bc-0c1f-46d9-9333-89ebe2bac3d0	Support Laser (Semi-Portable)	supportlasersemiportable	ALIAS
79093830-6de1-49f9-9060-b7187cb1a1cd	SV Chassis Mod [Amphibious]	svchassismodamphibious	ALIAS
838be605-4458-46c2-a7f7-2b46f8d975cf	SV Chassis Mod [Bicycle]	svchassismodbicycle	ALIAS
2b4ab52e-c6ba-4660-bf76-7acaf2f9af35	SV Chassis Mod [Convertible]	svchassismodconvertible	ALIAS
73157097-513b-477d-a6fe-758aedfa5b2d	SV Chassis Mod [Dune Buggy]	svchassismoddunebuggy	ALIAS
35f0cf50-ae10-4885-8b2e-59c5e19a7907	SV Chassis Mod [HydroFoil]	svchassismodhydrofoil	ALIAS
e7d50833-89c1-474c-b949-3280f60b434a	SV Chassis Mod [Monocycle]	svchassismodmonocycle	ALIAS
436bac82-4ca9-43d2-bca2-0cb69d00f28b	SV Chassis Mod [Omni]	svchassismodomni	ALIAS
cbbab1b3-94a0-4fb8-8f6f-1ea37477c4ad	SV Chassis Mod [Snowmobile]	svchassismodsnowmobile	ALIAS
e0af8ed7-0d9c-4362-b299-c8b1fc15f89b	SV Chassis Mod [Submersible]	svchassismodsubmersible	ALIAS
ff3cc865-d932-410c-a2c1-79adff239758	SV Chassis Mod [Tractor]	svchassismodtractor	ALIAS
6cdfda5c-3eb4-42c3-aa53-c78b11f0a8cb	SV Chassis Mod [Trailer]	svchassismodtrailer	ALIAS
a744c5af-0ed2-41f0-aa53-367b4e72730d	SV Chassis Mod [Ultra-Light]	svchassismodultralight	ALIAS
33e4d950-5e38-43d6-b726-ad55e14de305	SVDuneBuggy	svdunebuggy	ALIAS
5f9a3226-e112-4486-ac32-036dc20f5966	SVDuneBuggyChassis	svdunebuggychassis	ALIAS
d83867f9-e813-478b-a644-c64ab9f4002f	TAG (Light, Man-Portable)	taglightmanportable	ALIAS
0a6e70d8-3dc9-4d0e-a334-409c3d508d0b	Tank Sprayer	tanksprayer	ALIAS
0e736fe5-a138-499b-9b10-354e0b904550	Tractor	tractor	ALIAS
2ce9b007-cdd7-4bf4-99e6-5ad3ba9ef190	TractorChassisMod	tractorchassismod	ALIAS
76d8acb5-44fb-4be8-8005-22f330207deb	Trailer	trailer	ALIAS
fb4e35a0-f0ca-40d5-b56f-230eb17b80a8	TrailerChassisMod	trailerchassismod	ALIAS
54bd92a7-9293-4b36-a76a-1bad6f8e5886	UltraLightChassisMod	ultralightchassismod	ALIAS
45ebdafd-dc46-4b2b-8836-e344b109623c	Wire-Guided Missile Launcher	wireguidedmissilelauncher	ALIAS
\.

INSERT INTO slang (id, term, lookup, kind)
SELECT v.id, v.term, v.lookup, v.kind FROM v3_22_slang v
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = v.lookup);

COPY v3_22_link (lookup, name, tech) FROM stdin;
ac20p	primitiveprototypeautocannon/20	INNER_SPHERE
ac20pammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
ammoac20primitive	primitiveprototypeautocannon/20ammo	INNER_SPHERE
amphibiouschassis	svchassismod[amphibious]	INNER_SPHERE
amphibiouschassismod	svchassismod[amphibious]	INNER_SPHERE
autocannon20primitive	primitiveprototypeautocannon/20	INNER_SPHERE
autocannon20primitiveammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
autocannonbearhuntersuperheavy	autocannon(bearhuntersuperheavy)	CLAN
autocannonsemiportable	autocannon(semi-portable)	INNER_SPHERE
autorifle	auto-rifle(modern,generic)	INNER_SPHERE
autoriflemoderngeneric	auto-rifle(modern,generic)	INNER_SPHERE
baautogl	grenadelauncher(heavy)	INNER_SPHERE
bagrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
baheavygl	grenadelauncher(heavy)	INNER_SPHERE
baheavygrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
baplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
bicyclechassismod	svchassismod[bicycle]	CLAN
bicyclechassismod	svchassismod[bicycle]	INNER_SPHERE
bridgelayerheavy	bridgelayer(heavy)	INNER_SPHERE
convertiblechassismod	svchassismod[convertible]	INNER_SPHERE
dunebuggychassismod	svchassismod[dunebuggy]	INNER_SPHERE
fieldkitchen	fieldkitchen	INNER_SPHERE
fluidsuctionsystem	fluidsuctionsystem(standard)	INNER_SPHERE
fluidsuctionsystemstandard	fluidsuctionsystem(standard)	INNER_SPHERE
gaussriflelightkingdavid	gaussrifle,light(kingdavid)	INNER_SPHERE
grenadelauncherauto	grenadelauncher(auto)	INNER_SPHERE
grenadelauncherheavy	grenadelauncher(heavy)	INNER_SPHERE
heavybagrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
heavybridgelayer	bridgelayer(heavy)	INNER_SPHERE
hhsearchlight	searchlight(handheld)	INNER_SPHERE
highresimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
hydrofoilchassismod	svchassismod[hydrofoil]	INNER_SPHERE
infantry2shotsrm	srmlauncher(std,two-shot)	INNER_SPHERE
infantryassaultrifle	auto-rifle(modern,generic)	INNER_SPHERE
infantryautogl	grenadelauncher(auto)	INNER_SPHERE
infantryautogrenadelauncher	grenadelauncher(auto)	INNER_SPHERE
infantryautomaticrifle	auto-rifle(modern,generic)	INNER_SPHERE
infantryautorifle	auto-rifle(modern,generic)	INNER_SPHERE
infantrybearhunter	autocannon(bearhuntersuperheavy)	CLAN
infantrybearhunterautocannon	autocannon(bearhuntersuperheavy)	CLAN
infantrybearhuntersuperheavyautocannon	autocannon(bearhuntersuperheavy)	CLAN
infantryclanmauseriic	laserrifle(mauseriicias)	CLAN
infantryclanmauseriicias	laserrifle(mauseriicias)	CLAN
infantryheavygrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
infantryheavylaser	supportlaser(heavy)	INNER_SPHERE
infantryheavyrecoillessrifle	recoillessrifle(heavy)	INNER_SPHERE
infantryhmg	machinegun(support)	INNER_SPHERE
infantryhrr	recoillessrifle(heavy)	INNER_SPHERE
infantrykingdavid	gaussrifle,light(kingdavid)	INNER_SPHERE
infantrykingdavidlightgaussrifle	gaussrifle,light(kingdavid)	INNER_SPHERE
infantrymediumlaser	supportlaser(heavy)	INNER_SPHERE
infantrymgsemiportable	machinegun(semi-portable)	INNER_SPHERE
infantrymppr	plasmarifle(man-portable)	INNER_SPHERE
infantryplasmaportable	plasmarifle(man-portable)	INNER_SPHERE
infantryplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
infantryportableautocannon	autocannon(semi-portable)	INNER_SPHERE
infantrysemimg	machinegun(semi-portable)	INNER_SPHERE
infantrysemiportableautocannon	autocannon(semi-portable)	INNER_SPHERE
infantrysemiportablelaser	supportlaser(semi-portable)	CLAN
infantrysmalllaser	supportlaser	INNER_SPHERE
infantrysrm	srmlauncher(light)	INNER_SPHERE
infantrysrmlight	srmlauncher(light)	INNER_SPHERE
infantrystandardsrm	srmlauncher(std,two-shot)	INNER_SPHERE
infantrysupportlaser	supportlaser	INNER_SPHERE
infantrysupportmachinegun	machinegun(support)	INNER_SPHERE
infantrysupportmg	machinegun(support)	INNER_SPHERE
infantrytag	tag(light,man-portable)	INNER_SPHERE
infantrytwoshotsrmlauncher	srmlauncher(std,two-shot)	INNER_SPHERE
infantrywireguidedmissilelauncher	wire-guidedmissilelauncher	INNER_SPHERE
infraredimager	satelliteimager(infraredimager)	INNER_SPHERE
isac20p	primitiveprototypeautocannon/20	INNER_SPHERE
isac20pammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
isammoac20primitive	primitiveprototypeautocannon/20ammo	INNER_SPHERE
isautocannon20primitive	primitiveprototypeautocannon/20	INNER_SPHERE
isautocannon20primitiveammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
isbaautogl	grenadelauncher(heavy)	INNER_SPHERE
isbagrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
isbaheavygl	grenadelauncher(heavy)	INNER_SPHERE
isbaheavygrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
isbaplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
ishighresimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
isinfraredimager	satelliteimager(infraredimager)	INNER_SPHERE
issvdunebuggy	svchassismod[dunebuggy]	INNER_SPHERE
issvdunebuggychassis	svchassismod[dunebuggy]	INNER_SPHERE
ladder	ladder	INNER_SPHERE
ladder100m	ladder	INNER_SPHERE
ladder20m	ladder	INNER_SPHERE
ladder40m	ladder	INNER_SPHERE
ladder60m	ladder	INNER_SPHERE
ladder80m	ladder	INNER_SPHERE
laserriflemauseriicias	laserrifle(mauseriicias)	CLAN
lightsrmlauncher	srmlauncher(light)	INNER_SPHERE
machinegunsemiportable	machinegun(semi-portable)	INNER_SPHERE
machinegunsupport	machinegun(support)	INNER_SPHERE
manipulator	manipulator(non-mech/non-battlearmor)	INNER_SPHERE
manipulatornonmechnonbattlearmor	manipulator(non-mech/non-battlearmor)	INNER_SPHERE
monocyclechassismod	svchassismod[monocycle]	INNER_SPHERE
omnichassismod	svchassismod[omni]	CLAN
omnichassismod	svchassismod[omni]	INNER_SPHERE
pintlemount	pintlemount	INNER_SPHERE
pintleturret	pintlemount	INNER_SPHERE
plasmariflemanportable	plasmarifle(man-portable)	INNER_SPHERE
portableplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
primitiveprototypeautocannon20	primitiveprototypeautocannon/20	INNER_SPHERE
primitiveprototypeautocannon20ammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
recoillessrifleheavy	recoillessrifle(heavy)	INNER_SPHERE
satelliteimagerhighresolutionhiresimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
satelliteimagerhighresolutionimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
satelliteimagerinfraredimager	satelliteimager(infraredimager)	INNER_SPHERE
searchlighthandheld	searchlight(handheld)	INNER_SPHERE
snowmobilechassis	svchassismod[snowmobile]	INNER_SPHERE
snowmobilechassismod	svchassismod[snowmobile]	INNER_SPHERE
sprayervehicular	sprayer(vehicular)	INNER_SPHERE
srmlauncherlight	srmlauncher(light)	INNER_SPHERE
srmlauncherstdtwoshot	srmlauncher(std,two-shot)	INNER_SPHERE
submersiblechassismod	svchassismod[submersible]	INNER_SPHERE
supportlaser	supportlaser	INNER_SPHERE
supportlaserheavy	supportlaser(heavy)	INNER_SPHERE
supportlasersemiportable	supportlaser(semi-portable)	CLAN
svchassismodamphibious	svchassismod[amphibious]	INNER_SPHERE
svchassismodbicycle	svchassismod[bicycle]	CLAN
svchassismodbicycle	svchassismod[bicycle]	INNER_SPHERE
svchassismodconvertible	svchassismod[convertible]	INNER_SPHERE
svchassismoddunebuggy	svchassismod[dunebuggy]	INNER_SPHERE
svchassismodhydrofoil	svchassismod[hydrofoil]	INNER_SPHERE
svchassismodmonocycle	svchassismod[monocycle]	INNER_SPHERE
svchassismodomni	svchassismod[omni]	CLAN
svchassismodomni	svchassismod[omni]	INNER_SPHERE
svchassismodsnowmobile	svchassismod[snowmobile]	INNER_SPHERE
svchassismodsubmersible	svchassismod[submersible]	INNER_SPHERE
svchassismodtractor	svchassismod[tractor]	INNER_SPHERE
svchassismodtrailer	svchassismod[trailer]	INNER_SPHERE
svchassismodultralight	svchassismod[ultra-light]	INNER_SPHERE
svdunebuggy	svchassismod[dunebuggy]	INNER_SPHERE
svdunebuggychassis	svchassismod[dunebuggy]	INNER_SPHERE
taglightmanportable	tag(light,man-portable)	INNER_SPHERE
tanksprayer	sprayer(vehicular)	INNER_SPHERE
tractor	svchassismod[tractor]	INNER_SPHERE
tractorchassismod	svchassismod[tractor]	INNER_SPHERE
trailer	svchassismod[trailer]	INNER_SPHERE
trailerchassismod	svchassismod[trailer]	INNER_SPHERE
ultralightchassismod	svchassismod[ultra-light]	INNER_SPHERE
wireguidedmissilelauncher	wire-guidedmissilelauncher	INNER_SPHERE
\.

INSERT INTO slang_equipment (slang_id, equipment_id)
SELECT s.id, e.id
FROM v3_22_link l
JOIN slang s ON s.lookup = l.lookup
JOIN equipment e ON e.name = l.name AND e.tech IS NOT DISTINCT FROM l.tech
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- 5.
UPDATE unit_equipment ue SET equipment_id = vf.id
FROM unit u, unit_mech_equipment um, equipment f, equipment vf
WHERE u.megamek_uuid = '019f583e-ec7e-7b9b-b6bb-40be930a143f'
  AND um.unit_id = u.id AND um.mech_equipment_id = ue.id
  AND ue.location IN ('LEFT', 'RIGHT')
  AND ue.equipment_id = f.id AND f.name = 'flamer' AND f.tech = 'INNER_SPHERE'
  AND vf.name = 'flamer(vehicle)' AND vf.tech = 'INNER_SPHERE';

DROP TABLE v3_22_equipment, v3_22_unit, v3_22_item, v3_22_new_item, v3_22_slang, v3_22_link;
