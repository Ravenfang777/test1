-- Kingdom Hearts Final Mix - Sora model proportion scaler v7
-- Based on the pointer/version layout used by "Player Size.lua" by KSX.
--
-- Features
--   * Whole-model X/Y/Z scale through Sora's live object transform.
--   * Short, plain-language scale-control table for normal editing.
--   * Complete 293-joint grouped reference catalog for joint lookup.
--   * Immediate and next-frame verification of every enabled joint write.
--   * Direct, signature-checked runtime path; no broad pointer scan.
--   * Steam Global / Steam JP regional scaling.
--   * Epic Global whole-model scaling only (regional pointer banks unverified).
--
-- Runtime path verified from KH1FM_Model_Runtime_Locator_v1:
--   Sora + 0x154 -> compressed MOBJ pointer
--   MOBJ + 0x20 -> compressed model-header pointer
--   Model + 0x04 -> compressed joint-table pointer
--
-- The supplied xa_ex_0010.mdls has 293 zero-based joints. The catalog below maps every FBX Bone0-Bone292 directly to runtime joint 0-292.
-- Anatomical labels are hierarchy-based; direct vertex counts come from all nine FBX skin clusters.
-- Regional scaling is visual and does not resize collision or hit boxes. Scaling a parent also transforms every descendant listed in its catalog entry.

LUAGUI_NAME = "KH1FM Model Proportion Scaler v7"
LUAGUI_AUTH = "OpenAI / based on KSX Player Size"
LUAGUI_DESC = "Easy scale controls plus a complete grouped 293-joint reference"

-- ========================================================================
-- EASY SETTINGS: EDIT THIS SECTION
-- ========================================================================
-- 1.00 = original size, 1.25 = 125%, 0.80 = 80%.
-- Each value is an absolute scale and must remain between 0.01 and 20.00.
--
-- WHOLE_MODEL changes all of Sora at once.
--
-- MY_SCALE_CONTROLS changes selected joints:
--   enabled = true     turns that row on
--   enabled = false    leaves that row off
--   joint              joint ID from the reference table below
--   label              any helpful name you want to see in the F2 console
--   X / Y / Z          scale on that joint's LOCAL axes
--
-- To control another body part, copy one complete row, choose a joint ID from
-- JOINT REFERENCE, change its label, and set enabled = true.
--
-- Avoid enabling a parent and its child at the same time unless you want their
-- scale values to multiply. The script prints an overlap warning when it finds
-- that situation.
local SETTINGS = {
    WHOLE_MODEL = {
        X = 1.15,
        Y = 1.15,
        Z = 1.15,
    },

    MY_SCALE_CONTROLS = {
        {
            enabled = true,
            joint = 150,
            label = "Head, face, and all hair",
            X = .82,
            Y = .82,
            Z = .82,
        },
        {
            enabled = true,
            joint = 16,
            label = "Left Leg",
            X = 1.05,
            Y = 1.05,
            Z = 1.05,
        },
        {
            enabled = true,
            joint = 21,
            label = "Left Foot and Shoe",
            X = .8,
            Y = .7,
            Z = .5,
        },
        {
            enabled = true,
            joint = 42,
            label = "Right Leg",
            X = 1.05,
            Y = 1.05,
            Z = 1.05,
        },
        {
            enabled = true,
            joint = 47,
            label = "Right Foot and Shoe",
            X = .8,
            Y = .7,
            Z = .56,
        },
        {
            enabled = false,
            joint = 68,
            label = "Upper Body",
            X = 1,
            Y = 1,
            Z = 1,
        },
        {
            enabled = true,
            joint = 89,
            label = "Left Arm",
            X = .95,
            Y = .95,
            Z = 1.02,
        },
        {
            enabled = true,
            joint = 194,
            label = "Right Arm",
            X = .95,
            Y = .95,
            Z = 1.02,
        },
        {
            enabled = true,
            joint = 77,
            label = "Chest",
            X = 1.05,
            Y = 1.05,
            Z = 1.05,
        },

        -- Copy this block to add another joint:
        -- {
        --     enabled = true,
        --     joint = 16,
        --     label = "Complete left leg",
        --     X = 2.00,
        --     Y = 2.00,
        --     Z = 2.00,
        -- },

    },

    BLENDER_INDEX_BASE = 0,
    VERIFY_JOINT_WRITES = true,
    VERIFY_STABLE_AFTER_TICKS = 2,
    WARN_OVERLAPPING_ENABLED_JOINTS = true,
    EXPECTED_JOINT_COUNT = 293,
}

-- ========================================================================
-- QUICK JOINT LOOKUP
-- ========================================================================
-- These are useful parent controls for changing a complete body section.
-- More specific joints, including every finger, hair strand, shoe segment,
-- clothing panel, and waist strap, are listed in JOINT REFERENCE below.
--
--   JOINT   SIMPLE DESCRIPTION                     ALSO CHANGES
--   -----   ------------------------------------   --------------------------
--     16    Complete left leg                      Thigh, shin, foot, panels
--     17    Left thigh                             Shin, foot, clothing panels
--     18    Left shin                              Ankle, foot, shoe
--     21    Left foot and shoe                     Forward shoe and toe
--     42    Complete right leg                     Thigh, shin, foot, panels
--     43    Right thigh                            Shin, foot, clothing panels
--     44    Right shin                             Ankle, foot, shoe
--     47    Right foot and shoe                    Forward shoe and toe
--     68    Complete upper body                    Torso, arms, head, clothing
--     77    Chest and upper torso                  Arms, neck, head, hair
--     79    Front chest accessory                  Its full hanging chain
--     85    Front necklace/cord                    Its full hanging chain
--     89    Complete left arm                      Hand, fingers, sleeve pieces
--     93    Left upper arm                         Forearm, hand, fingers
--     94    Left forearm                           Wrist, hand, fingers
--    100    Left palm                              All left fingers
--    144    Neck, head, face, and hair             Complete head chain
--    150    Head and face                          Every hair strand
--    151    All hair                               Fourteen hair strands
--    194    Complete right arm                     Hand, fingers, sleeve pieces
--    198    Right upper arm                        Forearm, hand, fingers
--    199    Right forearm                          Wrist, hand, fingers
--    205    Right palm                             All right fingers
--    248    Right waist strap 1                    Entire strap
--    252    Right waist strap 2                    Entire strap
--    256    Right waist strap 3                    Entire strap
--    260    Right waist strap 4                    Entire strap
--    264    Left waist strap 1                     Entire strap
--    268    Left waist strap 2                     Entire strap
--    272    Left waist strap 3                     Entire strap
--    276    Left waist strap 4                     Entire strap

-- ========================================================================
-- JOINT REFERENCE: LOOK UP AN ID HERE; NORMAL USERS DO NOT EDIT THIS
-- ========================================================================
-- Each reference row is arranged as:
--
--   R(ID, PARENT, "SHORT NAME", "WHAT SCALING IT CHANGES",
--     DIRECT VERTICES, "CHILD JOINTS ALSO AFFECTED")
--
-- ID:
--   Put this number in MY_SCALE_CONTROLS.
--
-- PARENT:
--   The joint immediately above this one. Scaling that parent also affects
--   this joint.
--
-- WHAT SCALING IT CHANGES:
--   The visible region moved by this joint, including its child joints.
--
-- DIRECT VERTICES:
--   Technical FBX skin-weight count. A value of 0 does NOT mean the joint does
--   nothing; it may still transform all child joints listed in the last column.
--
-- CHILD JOINTS ALSO AFFECTED:
--   Additional descendants that inherit the selected joint's scale.
local function R(joint, parent, name, affected, directVertices, descendants)
    return {
        joint = joint, parent = parent, name = name, affected = affected,
        direct_vertices = directVertices, descendants = descendants,
    }
end

local JOINT_REFERENCE = {
        {
            name = "Model and pelvis roots",
            affected = "Master roots, pelvis, hips, and central lower-body auxiliaries",
            joints = {
                R(0, nil, "MODEL_SKELETON_ROOT", "Entire model skeleton and every joint below it", 0, "1-292"),
                R(1, 0, "PELVIS_ORIENTATION_ROOT", "Pelvis, hips, both legs, feet, and lower-body auxiliary chains", 0, "2-67"),
                R(2, 1, "PELVIS_MASTER", "Hips, both legs, feet, and lower-body auxiliary chains", 201, "3-67"),
                R(3, 2, "HIPS_AND_LEGS_MASTER", "Central hips plus both complete leg branches", 0, "4-67"),
                R(4, 3, "CENTER_HIP_AUXILIARY_01", "Central lower-body auxiliary chain", 0, "5-9"),
                R(5, 4, "CENTER_HIP_AUXILIARY_02", "Central lower-body auxiliary chain", 66, "6-9"),
                R(6, 5, "CENTER_HIP_AUXILIARY_03", "Central lower-body auxiliary chain", 0, "7-9"),
                R(7, 6, "CENTER_HIP_AUXILIARY_04", "Central lower-body auxiliary chain", 0, "8-9"),
                R(8, 7, "CENTER_HIP_AUXILIARY_05", "Central lower-body auxiliary chain", 7, "9"),
                R(9, 8, "CENTER_HIP_AUXILIARY_06", "Central lower-body auxiliary chain", 0, "none"),
                R(10, 3, "FRONT_PELVIS_AUXILIARY_01", "Front/center pelvis auxiliary chain", 0, "11-15"),
                R(11, 10, "FRONT_PELVIS_AUXILIARY_02", "Front/center pelvis auxiliary chain", 0, "12-15"),
                R(12, 11, "FRONT_PELVIS_AUXILIARY_03", "Front/center pelvis auxiliary chain", 12, "13-15"),
                R(13, 12, "FRONT_PELVIS_AUXILIARY_04", "Front/center pelvis auxiliary chain", 12, "14-15"),
                R(14, 13, "FRONT_PELVIS_AUXILIARY_05", "Front/center pelvis auxiliary chain", 36, "15"),
                R(15, 14, "FRONT_PELVIS_AUXILIARY_06", "Front/center pelvis auxiliary chain", 0, "none"),
            },
        },
        {
            name = "Left leg, foot, shoe, and clothing panels",
            affected = "Left leg, foot, shoe, and upper-leg clothing panels",
            joints = {
                R(16, 3, "LEFT_LEG_ATTACHMENT_ROOT", "LEFT complete leg, foot, and four upper-leg clothing panels", 0, "17-41"),
                R(17, 16, "LEFT_UPPER_LEG_THIGH", "LEFT thigh plus lower leg, foot, and four attached clothing panels", 48, "18-41"),
                R(18, 17, "LEFT_LOWER_LEG_SHIN", "LEFT shin, ankle, foot, and shoe-tip branch", 163, "19-25"),
                R(19, 18, "LEFT_ANKLE_TRANSITION", "LEFT ankle, foot, and shoe-tip branch", 0, "20-25"),
                R(20, 19, "LEFT_FOOT_ORIENTATION", "LEFT foot and shoe-tip branch", 0, "21-25"),
                R(21, 20, "LEFT_FOOT_AND_SHOE", "LEFT foot and forward shoe chain", 139, "22-25"),
                R(22, 21, "LEFT_FOOT_FORWARD_BRANCH_ROOT", "LEFT forward foot branch plus shoe-tip descendants", 0, "23-25"),
                R(23, 22, "LEFT_SHOE_TIP_BRANCH_ROOT", "LEFT shoe-tip branch", 0, "24-25"),
                R(24, 23, "LEFT_SHOE_TIP_DEFORM", "LEFT shoe-tip geometry and endpoint", 81, "25"),
                R(25, 24, "LEFT_SHOE_TIP_END", "LEFT shoe-tip endpoint; no child geometry", 0, "none"),
                R(26, 17, "LEFT_UPPER_LEG_CLOTHING_PANEL_1_01", "LEFT upper-leg clothing panel 1", 0, "27-29"),
                R(27, 26, "LEFT_UPPER_LEG_CLOTHING_PANEL_1_02", "LEFT upper-leg clothing panel 1", 15, "28-29"),
                R(28, 27, "LEFT_UPPER_LEG_CLOTHING_PANEL_1_03", "LEFT upper-leg clothing panel 1", 34, "29"),
                R(29, 28, "LEFT_UPPER_LEG_CLOTHING_PANEL_1_04", "LEFT upper-leg clothing panel 1", 0, "none"),
                R(30, 17, "LEFT_UPPER_LEG_CLOTHING_PANEL_2_01", "LEFT upper-leg clothing panel 2", 0, "31-33"),
                R(31, 30, "LEFT_UPPER_LEG_CLOTHING_PANEL_2_02", "LEFT upper-leg clothing panel 2", 12, "32-33"),
                R(32, 31, "LEFT_UPPER_LEG_CLOTHING_PANEL_2_03", "LEFT upper-leg clothing panel 2", 16, "33"),
                R(33, 32, "LEFT_UPPER_LEG_CLOTHING_PANEL_2_04", "LEFT upper-leg clothing panel 2", 0, "none"),
                R(34, 17, "LEFT_UPPER_LEG_CLOTHING_PANEL_3_01", "LEFT upper-leg clothing panel 3", 0, "35-37"),
                R(35, 34, "LEFT_UPPER_LEG_CLOTHING_PANEL_3_02", "LEFT upper-leg clothing panel 3", 16, "36-37"),
                R(36, 35, "LEFT_UPPER_LEG_CLOTHING_PANEL_3_03", "LEFT upper-leg clothing panel 3", 33, "37"),
                R(37, 36, "LEFT_UPPER_LEG_CLOTHING_PANEL_3_04", "LEFT upper-leg clothing panel 3", 0, "none"),
                R(38, 17, "LEFT_UPPER_LEG_CLOTHING_PANEL_4_01", "LEFT upper-leg clothing panel 4", 0, "39-41"),
                R(39, 38, "LEFT_UPPER_LEG_CLOTHING_PANEL_4_02", "LEFT upper-leg clothing panel 4", 9, "40-41"),
                R(40, 39, "LEFT_UPPER_LEG_CLOTHING_PANEL_4_03", "LEFT upper-leg clothing panel 4", 15, "41"),
                R(41, 40, "LEFT_UPPER_LEG_CLOTHING_PANEL_4_04", "LEFT upper-leg clothing panel 4", 0, "none"),
            },
        },
        {
            name = "Right leg, foot, shoe, and clothing panels",
            affected = "Right leg, foot, shoe, and upper-leg clothing panels",
            joints = {
                R(42, 3, "RIGHT_LEG_ATTACHMENT_ROOT", "RIGHT complete leg, foot, and four upper-leg clothing panels", 0, "43-67"),
                R(43, 42, "RIGHT_UPPER_LEG_THIGH", "RIGHT thigh plus lower leg, foot, and four attached clothing panels", 45, "44-67"),
                R(44, 43, "RIGHT_LOWER_LEG_SHIN", "RIGHT shin, ankle, foot, and shoe-tip branch", 169, "45-51"),
                R(45, 44, "RIGHT_ANKLE_TRANSITION", "RIGHT ankle, foot, and shoe-tip branch", 0, "46-51"),
                R(46, 45, "RIGHT_FOOT_ORIENTATION", "RIGHT foot and shoe-tip branch", 0, "47-51"),
                R(47, 46, "RIGHT_FOOT_AND_SHOE", "RIGHT foot and forward shoe chain", 130, "48-51"),
                R(48, 47, "RIGHT_FOOT_FORWARD_BRANCH_ROOT", "RIGHT forward foot branch plus shoe-tip descendants", 0, "49-51"),
                R(49, 48, "RIGHT_SHOE_TIP_BRANCH_ROOT", "RIGHT shoe-tip branch", 0, "50-51"),
                R(50, 49, "RIGHT_SHOE_TIP_DEFORM", "RIGHT shoe-tip geometry and endpoint", 75, "51"),
                R(51, 50, "RIGHT_SHOE_TIP_END", "RIGHT shoe-tip endpoint; no child geometry", 0, "none"),
                R(52, 43, "RIGHT_UPPER_LEG_CLOTHING_PANEL_1_01", "RIGHT upper-leg clothing panel 1", 0, "53-55"),
                R(53, 52, "RIGHT_UPPER_LEG_CLOTHING_PANEL_1_02", "RIGHT upper-leg clothing panel 1", 16, "54-55"),
                R(54, 53, "RIGHT_UPPER_LEG_CLOTHING_PANEL_1_03", "RIGHT upper-leg clothing panel 1", 31, "55"),
                R(55, 54, "RIGHT_UPPER_LEG_CLOTHING_PANEL_1_04", "RIGHT upper-leg clothing panel 1", 0, "none"),
                R(56, 43, "RIGHT_UPPER_LEG_CLOTHING_PANEL_2_01", "RIGHT upper-leg clothing panel 2", 0, "57-59"),
                R(57, 56, "RIGHT_UPPER_LEG_CLOTHING_PANEL_2_02", "RIGHT upper-leg clothing panel 2", 11, "58-59"),
                R(58, 57, "RIGHT_UPPER_LEG_CLOTHING_PANEL_2_03", "RIGHT upper-leg clothing panel 2", 16, "59"),
                R(59, 58, "RIGHT_UPPER_LEG_CLOTHING_PANEL_2_04", "RIGHT upper-leg clothing panel 2", 0, "none"),
                R(60, 43, "RIGHT_UPPER_LEG_CLOTHING_PANEL_3_01", "RIGHT upper-leg clothing panel 3", 0, "61-63"),
                R(61, 60, "RIGHT_UPPER_LEG_CLOTHING_PANEL_3_02", "RIGHT upper-leg clothing panel 3", 20, "62-63"),
                R(62, 61, "RIGHT_UPPER_LEG_CLOTHING_PANEL_3_03", "RIGHT upper-leg clothing panel 3", 31, "63"),
                R(63, 62, "RIGHT_UPPER_LEG_CLOTHING_PANEL_3_04", "RIGHT upper-leg clothing panel 3", 0, "none"),
                R(64, 43, "RIGHT_UPPER_LEG_CLOTHING_PANEL_4_01", "RIGHT upper-leg clothing panel 4", 0, "65-67"),
                R(65, 64, "RIGHT_UPPER_LEG_CLOTHING_PANEL_4_02", "RIGHT upper-leg clothing panel 4", 10, "66-67"),
                R(66, 65, "RIGHT_UPPER_LEG_CLOTHING_PANEL_4_03", "RIGHT upper-leg clothing panel 4", 15, "67"),
                R(67, 66, "RIGHT_UPPER_LEG_CLOTHING_PANEL_4_04", "RIGHT upper-leg clothing panel 4", 0, "none"),
            },
        },
        {
            name = "Torso, spine, chest, and necklace",
            affected = "Torso, spine, chest, and necklace/chest accessory chains",
            joints = {
                R(68, 0, "UPPER_BODY_SKELETON_ROOT", "Entire torso, arms, hands, neck, head, hair, waist straps, and hand-attachment chain", 0, "69-292"),
                R(69, 68, "LOWER_TORSO_ROOT", "Lower torso and every upper-body branch", 32, "70-292"),
                R(70, 69, "LOWER_SPINE", "Waist, torso, arms, neck, head, hair, and waist straps", 85, "71-292"),
                R(71, 70, "WAIST_AND_TORSO_HUB", "Torso, both arms, neck/head/hair, and all eight waist clothing straps", 0, "72-292"),
                R(72, 71, "LOWER_FRONT_TORSO_DETAIL_01", "Lower-front torso detail chain", 0, "73-75"),
                R(73, 72, "LOWER_FRONT_TORSO_DETAIL_02", "Lower-front torso detail chain", 11, "74-75"),
                R(74, 73, "LOWER_FRONT_TORSO_DETAIL_03", "Lower-front torso detail chain", 13, "75"),
                R(75, 74, "LOWER_FRONT_TORSO_DETAIL_04", "Lower-front torso detail chain", 0, "none"),
                R(76, 71, "MID_SPINE_ORIENTATION", "Chest, shoulders, arms, neck, head, and hair", 0, "77-247,280-292"),
                R(77, 76, "CHEST_TORSO", "Chest, shoulders, arms, neck, head, and hair", 241, "78-247,280-292"),
                R(78, 77, "UPPER_TORSO_BRANCH_HUB", "Both arms/hands, neck/head/hair, and chest accessories", 0, "79-247,280-292"),
                R(79, 78, "FRONT_CHEST_ACCESSORY_CHAIN_1_01", "Front chest/necklace accessory chain 1", 0, "80-84"),
                R(80, 79, "FRONT_CHEST_ACCESSORY_CHAIN_1_02", "Front chest/necklace accessory chain 1", 0, "81-84"),
                R(81, 80, "FRONT_CHEST_ACCESSORY_CHAIN_1_03", "Front chest/necklace accessory chain 1", 45, "82-84"),
                R(82, 81, "FRONT_CHEST_ACCESSORY_CHAIN_1_04", "Front chest/necklace accessory chain 1", 34, "83-84"),
                R(83, 82, "FRONT_CHEST_ACCESSORY_CHAIN_1_05", "Front chest/necklace accessory chain 1", 37, "84"),
                R(84, 83, "FRONT_CHEST_ACCESSORY_CHAIN_1_06", "Front chest/necklace accessory chain 1", 0, "none"),
                R(85, 78, "FRONT_NECKLACE_CHAIN_2_01", "Front necklace/cord chain 2", 0, "86-88"),
                R(86, 85, "FRONT_NECKLACE_CHAIN_2_02", "Front necklace/cord chain 2", 23, "87-88"),
                R(87, 86, "FRONT_NECKLACE_CHAIN_2_03", "Front necklace/cord chain 2", 67, "88"),
                R(88, 87, "FRONT_NECKLACE_CHAIN_2_04", "Front necklace/cord chain 2", 0, "none"),
            },
        },
        {
            name = "Left arm, hand, fingers, and sleeve pieces",
            affected = "Left arm, hand, five fingers, and arm/sleeve accessory strips",
            joints = {
                R(89, 78, "LEFT_CLAVICLE_ROOT", "LEFT complete arm, hand, fingers, and four arm-accessory strips", 0, "90-143,280-292"),
                R(90, 89, "LEFT_SHOULDER", "LEFT complete arm, hand, fingers, and arm accessories", 32, "91-143,280-292"),
                R(91, 90, "LEFT_UPPER_ARM_TRANSITION", "LEFT upper arm, forearm, hand, fingers, and arm accessories", 0, "92-143,280-292"),
                R(92, 91, "LEFT_UPPER_ARM_ORIENTATION", "LEFT upper arm, forearm, hand, fingers, and arm accessories", 0, "93-143,280-292"),
                R(93, 92, "LEFT_UPPER_ARM", "LEFT upper arm, forearm, hand, fingers, and arm accessories", 72, "94-143,280-292"),
                R(94, 93, "LEFT_FOREARM", "LEFT forearm, wrist, hand, and fingers", 54, "95-127,280-292"),
                R(95, 94, "LEFT_WRIST_TRANSITION", "LEFT wrist, hand, and fingers", 0, "96-127,280-292"),
                R(96, 95, "LEFT_HAND_ORIENTATION", "LEFT hand and all fingers", 0, "97-127,280-292"),
                R(97, 96, "LEFT_WRIST", "LEFT wrist/hand and all fingers", 48, "98-127,280-292"),
                R(98, 97, "LEFT_HAND_CONNECTOR", "LEFT palm and all fingers", 0, "99-127,280-292"),
                R(99, 98, "LEFT_PALM_ORIENTATION", "LEFT palm and all fingers", 0, "100-127,280-292"),
                R(100, 99, "LEFT_PALM", "LEFT palm and all finger branches", 124, "101-127,280-292"),
                R(101, 100, "LEFT_FINGER_BRANCH_HUB", "LEFT thumb, index, middle, ring, and pinky branches", 0, "102-127,280-292"),
                R(102, 101, "LEFT_HAND_ATTACHMENT_SOCKET", "LEFT terminal hand attachment socket; no weighted vertices", 0, "none"),
                R(103, 101, "LEFT_THUMB_ROOT", "left thumb chain", 0, "104-107"),
                R(104, 103, "LEFT_THUMB_PROXIMAL", "left thumb chain", 20, "105-107"),
                R(105, 104, "LEFT_THUMB_MIDDLE", "left thumb chain", 31, "106-107"),
                R(106, 105, "LEFT_THUMB_DISTAL", "left thumb chain", 27, "107"),
                R(107, 106, "LEFT_THUMB_TIP", "left thumb chain; terminal tip", 0, "none"),
                R(108, 101, "LEFT_INDEX_FINGER_ROOT", "left index finger chain", 0, "109-112"),
                R(109, 108, "LEFT_INDEX_FINGER_PROXIMAL", "left index finger chain", 30, "110-112"),
                R(110, 109, "LEFT_INDEX_FINGER_MIDDLE", "left index finger chain", 25, "111-112"),
                R(111, 110, "LEFT_INDEX_FINGER_DISTAL", "left index finger chain", 28, "112"),
                R(112, 111, "LEFT_INDEX_FINGER_TIP", "left index finger chain; terminal tip", 0, "none"),
                R(113, 101, "LEFT_MIDDLE_FINGER_ROOT", "left middle finger chain", 0, "114-117"),
                R(114, 113, "LEFT_MIDDLE_FINGER_PROXIMAL", "left middle finger chain", 33, "115-117"),
                R(115, 114, "LEFT_MIDDLE_FINGER_MIDDLE", "left middle finger chain", 24, "116-117"),
                R(116, 115, "LEFT_MIDDLE_FINGER_DISTAL", "left middle finger chain", 26, "117"),
                R(117, 116, "LEFT_MIDDLE_FINGER_TIP", "left middle finger chain; terminal tip", 0, "none"),
                R(118, 101, "LEFT_RING_FINGER_ROOT", "left ring finger chain", 0, "119-122"),
                R(119, 118, "LEFT_RING_FINGER_PROXIMAL", "left ring finger chain", 32, "120-122"),
                R(120, 119, "LEFT_RING_FINGER_MIDDLE", "left ring finger chain", 27, "121-122"),
                R(121, 120, "LEFT_RING_FINGER_DISTAL", "left ring finger chain", 31, "122"),
                R(122, 121, "LEFT_RING_FINGER_TIP", "left ring finger chain; terminal tip", 0, "none"),
                R(123, 101, "LEFT_PINKY_ROOT", "left pinky chain", 0, "124-127"),
                R(124, 123, "LEFT_PINKY_PROXIMAL", "left pinky chain", 29, "125-127"),
                R(125, 124, "LEFT_PINKY_MIDDLE", "left pinky chain", 28, "126-127"),
                R(126, 125, "LEFT_PINKY_DISTAL", "left pinky chain", 31, "127"),
                R(127, 126, "LEFT_PINKY_TIP", "left pinky chain; terminal tip", 0, "none"),
                R(128, 93, "LEFT_ARM_ACCESSORY_STRIP_1_01", "LEFT arm/sleeve accessory strip 1", 0, "129-131"),
                R(129, 128, "LEFT_ARM_ACCESSORY_STRIP_1_02", "LEFT arm/sleeve accessory strip 1", 9, "130-131"),
                R(130, 129, "LEFT_ARM_ACCESSORY_STRIP_1_03", "LEFT arm/sleeve accessory strip 1", 19, "131"),
                R(131, 130, "LEFT_ARM_ACCESSORY_STRIP_1_04", "LEFT arm/sleeve accessory strip 1", 0, "none"),
                R(132, 93, "LEFT_ARM_ACCESSORY_STRIP_2_01", "LEFT arm/sleeve accessory strip 2", 0, "133-135"),
                R(133, 132, "LEFT_ARM_ACCESSORY_STRIP_2_02", "LEFT arm/sleeve accessory strip 2", 4, "134-135"),
                R(134, 133, "LEFT_ARM_ACCESSORY_STRIP_2_03", "LEFT arm/sleeve accessory strip 2", 10, "135"),
                R(135, 134, "LEFT_ARM_ACCESSORY_STRIP_2_04", "LEFT arm/sleeve accessory strip 2", 0, "none"),
                R(136, 93, "LEFT_ARM_ACCESSORY_STRIP_3_01", "LEFT arm/sleeve accessory strip 3", 0, "137-139"),
                R(137, 136, "LEFT_ARM_ACCESSORY_STRIP_3_02", "LEFT arm/sleeve accessory strip 3", 10, "138-139"),
                R(138, 137, "LEFT_ARM_ACCESSORY_STRIP_3_03", "LEFT arm/sleeve accessory strip 3", 20, "139"),
                R(139, 138, "LEFT_ARM_ACCESSORY_STRIP_3_04", "LEFT arm/sleeve accessory strip 3", 0, "none"),
                R(140, 93, "LEFT_ARM_ACCESSORY_STRIP_4_01", "LEFT arm/sleeve accessory strip 4", 0, "141-143"),
                R(141, 140, "LEFT_ARM_ACCESSORY_STRIP_4_02", "LEFT arm/sleeve accessory strip 4", 7, "142-143"),
                R(142, 141, "LEFT_ARM_ACCESSORY_STRIP_4_03", "LEFT arm/sleeve accessory strip 4", 8, "143"),
                R(143, 142, "LEFT_ARM_ACCESSORY_STRIP_4_04", "LEFT arm/sleeve accessory strip 4", 0, "none"),
            },
        },
        {
            name = "Neck, head, face, and hair",
            affected = "Neck, head, face, and fourteen separately adjustable hair strands",
            joints = {
                R(144, 78, "NECK_ORIENTATION_ROOT", "Complete neck, head, face, and every hair strand", 0, "145-193"),
                R(145, 144, "LOWER_NECK_AND_HEAD_PARENT", "Lower neck plus complete neck/head/face/hair descendant chain", 33, "146-193"),
                R(146, 145, "MID_NECK", "Mid neck plus upper neck, head, face, and all hair", 42, "147-193"),
                R(147, 146, "UPPER_NECK", "Upper neck plus head, face, and all hair", 84, "148-193"),
                R(148, 147, "HEAD_TRANSITION", "Head, face, and all hair", 0, "149-193"),
                R(149, 148, "HEAD_ORIENTATION", "Head, face, and all hair", 0, "150-193"),
                R(150, 149, "HEAD_FACE_ROOT", "Head/face geometry and every hair strand", 975, "151-193"),
                R(151, 150, "ALL_HAIR_BRANCH_HUB", "All fourteen hair-strand branches; no direct weighted vertices", 0, "152-193"),
                R(152, 151, "LOWER_CENTER_HAIR_STRAND_ROOT", "lower center hair strand", 0, "153-154"),
                R(153, 152, "LOWER_CENTER_HAIR_STRAND_DEFORM", "lower center hair strand geometry and tip", 52, "154"),
                R(154, 153, "LOWER_CENTER_HAIR_STRAND_TIP", "lower center hair strand endpoint; no child geometry", 0, "none"),
                R(155, 151, "UPPER_LEFT_INNER_HAIR_STRAND_ROOT", "upper left inner hair strand", 0, "156-157"),
                R(156, 155, "UPPER_LEFT_INNER_HAIR_STRAND_DEFORM", "upper left inner hair strand geometry and tip", 5, "157"),
                R(157, 156, "UPPER_LEFT_INNER_HAIR_STRAND_TIP", "upper left inner hair strand endpoint; no child geometry", 0, "none"),
                R(158, 151, "LEFT_SIDE_OUTER_HAIR_STRAND_ROOT", "left side outer hair strand", 0, "159-160"),
                R(159, 158, "LEFT_SIDE_OUTER_HAIR_STRAND_DEFORM", "left side outer hair strand geometry and tip", 6, "160"),
                R(160, 159, "LEFT_SIDE_OUTER_HAIR_STRAND_TIP", "left side outer hair strand endpoint; no child geometry", 0, "none"),
                R(161, 151, "LOWER_LEFT_HAIR_STRAND_ROOT", "lower left hair strand", 0, "162-163"),
                R(162, 161, "LOWER_LEFT_HAIR_STRAND_DEFORM", "lower left hair strand geometry and tip", 7, "163"),
                R(163, 162, "LOWER_LEFT_HAIR_STRAND_TIP", "lower left hair strand endpoint; no child geometry", 0, "none"),
                R(164, 151, "UPPER_LEFT_OUTER_HAIR_STRAND_ROOT", "upper left outer hair strand", 0, "165-166"),
                R(165, 164, "UPPER_LEFT_OUTER_HAIR_STRAND_DEFORM", "upper left outer hair strand geometry and tip", 3, "166"),
                R(166, 165, "UPPER_LEFT_OUTER_HAIR_STRAND_TIP", "upper left outer hair strand endpoint; no child geometry", 0, "none"),
                R(167, 151, "TOP_LEFT_OUTER_HAIR_STRAND_ROOT", "top left outer hair strand", 0, "168-169"),
                R(168, 167, "TOP_LEFT_OUTER_HAIR_STRAND_DEFORM", "top left outer hair strand geometry and tip", 6, "169"),
                R(169, 168, "TOP_LEFT_OUTER_HAIR_STRAND_TIP", "top left outer hair strand endpoint; no child geometry", 0, "none"),
                R(170, 151, "TOP_LEFT_INNER_HAIR_STRAND_ROOT", "top left inner hair strand", 0, "171-172"),
                R(171, 170, "TOP_LEFT_INNER_HAIR_STRAND_DEFORM", "top left inner hair strand geometry and tip", 5, "172"),
                R(172, 171, "TOP_LEFT_INNER_HAIR_STRAND_TIP", "top left inner hair strand endpoint; no child geometry", 0, "none"),
                R(173, 151, "RIGHT_SIDE_OUTER_HAIR_STRAND_ROOT", "right side outer hair strand", 0, "174-175"),
                R(174, 173, "RIGHT_SIDE_OUTER_HAIR_STRAND_DEFORM", "right side outer hair strand geometry and tip", 4, "175"),
                R(175, 174, "RIGHT_SIDE_OUTER_HAIR_STRAND_TIP", "right side outer hair strand endpoint; no child geometry", 0, "none"),
                R(176, 151, "LOWER_RIGHT_HAIR_STRAND_ROOT", "lower right hair strand", 0, "177-178"),
                R(177, 176, "LOWER_RIGHT_HAIR_STRAND_DEFORM", "lower right hair strand geometry and tip", 8, "178"),
                R(178, 177, "LOWER_RIGHT_HAIR_STRAND_TIP", "lower right hair strand endpoint; no child geometry", 0, "none"),
                R(179, 151, "UPPER_RIGHT_OUTER_HAIR_STRAND_ROOT", "upper right outer hair strand", 0, "180-181"),
                R(180, 179, "UPPER_RIGHT_OUTER_HAIR_STRAND_DEFORM", "upper right outer hair strand geometry and tip", 2, "181"),
                R(181, 180, "UPPER_RIGHT_OUTER_HAIR_STRAND_TIP", "upper right outer hair strand endpoint; no child geometry", 0, "none"),
                R(182, 151, "TOP_RIGHT_OUTER_HAIR_STRAND_ROOT", "top right outer hair strand", 0, "183-184"),
                R(183, 182, "TOP_RIGHT_OUTER_HAIR_STRAND_DEFORM", "top right outer hair strand geometry and tip", 7, "184"),
                R(184, 183, "TOP_RIGHT_OUTER_HAIR_STRAND_TIP", "top right outer hair strand endpoint; no child geometry", 0, "none"),
                R(185, 151, "TOP_RIGHT_INNER_HAIR_STRAND_ROOT", "top right inner hair strand", 0, "186-187"),
                R(186, 185, "TOP_RIGHT_INNER_HAIR_STRAND_DEFORM", "top right inner hair strand geometry and tip", 5, "187"),
                R(187, 186, "TOP_RIGHT_INNER_HAIR_STRAND_TIP", "top right inner hair strand endpoint; no child geometry", 0, "none"),
                R(188, 151, "TOP_CENTER_HAIR_STRAND_ROOT", "top center hair strand", 0, "189-190"),
                R(189, 188, "TOP_CENTER_HAIR_STRAND_DEFORM", "top center hair strand geometry and tip", 14, "190"),
                R(190, 189, "TOP_CENTER_HAIR_STRAND_TIP", "top center hair strand endpoint; no child geometry", 0, "none"),
                R(191, 151, "UPPER_FRONT_CENTER_HAIR_STRAND_ROOT", "upper front center hair strand", 0, "192-193"),
                R(192, 191, "UPPER_FRONT_CENTER_HAIR_STRAND_DEFORM", "upper front center hair strand geometry and tip", 8, "193"),
                R(193, 192, "UPPER_FRONT_CENTER_HAIR_STRAND_TIP", "upper front center hair strand endpoint; no child geometry", 0, "none"),
            },
        },
        {
            name = "Right arm, hand, fingers, and sleeve pieces",
            affected = "Right arm, hand, five fingers, and arm/sleeve accessory strips",
            joints = {
                R(194, 78, "RIGHT_CLAVICLE_ROOT", "RIGHT complete arm, hand, fingers, and four arm-accessory strips", 0, "195-247"),
                R(195, 194, "RIGHT_SHOULDER", "RIGHT complete arm, hand, fingers, and arm accessories", 35, "196-247"),
                R(196, 195, "RIGHT_UPPER_ARM_TRANSITION", "RIGHT upper arm, forearm, hand, fingers, and arm accessories", 0, "197-247"),
                R(197, 196, "RIGHT_UPPER_ARM_ORIENTATION", "RIGHT upper arm, forearm, hand, fingers, and arm accessories", 0, "198-247"),
                R(198, 197, "RIGHT_UPPER_ARM", "RIGHT upper arm, forearm, hand, fingers, and arm accessories", 65, "199-247"),
                R(199, 198, "RIGHT_FOREARM", "RIGHT forearm, wrist, hand, and fingers", 55, "200-231"),
                R(200, 199, "RIGHT_WRIST_TRANSITION", "RIGHT wrist, hand, and fingers", 0, "201-231"),
                R(201, 200, "RIGHT_HAND_ORIENTATION", "RIGHT hand and all fingers", 0, "202-231"),
                R(202, 201, "RIGHT_WRIST", "RIGHT wrist/hand and all fingers", 47, "203-231"),
                R(203, 202, "RIGHT_HAND_CONNECTOR", "RIGHT palm and all fingers", 0, "204-231"),
                R(204, 203, "RIGHT_PALM_ORIENTATION", "RIGHT palm and all fingers", 0, "205-231"),
                R(205, 204, "RIGHT_PALM", "RIGHT palm and all finger branches", 127, "206-231"),
                R(206, 205, "RIGHT_FINGER_BRANCH_HUB", "RIGHT thumb, index, middle, ring, and pinky branches", 0, "207-231"),
                R(207, 206, "RIGHT_THUMB_ROOT", "right thumb chain", 0, "208-211"),
                R(208, 207, "RIGHT_THUMB_PROXIMAL", "right thumb chain", 18, "209-211"),
                R(209, 208, "RIGHT_THUMB_MIDDLE", "right thumb chain", 32, "210-211"),
                R(210, 209, "RIGHT_THUMB_DISTAL", "right thumb chain", 28, "211"),
                R(211, 210, "RIGHT_THUMB_TIP", "right thumb chain; terminal tip", 0, "none"),
                R(212, 206, "RIGHT_INDEX_FINGER_ROOT", "right index finger chain", 0, "213-216"),
                R(213, 212, "RIGHT_INDEX_FINGER_PROXIMAL", "right index finger chain", 33, "214-216"),
                R(214, 213, "RIGHT_INDEX_FINGER_MIDDLE", "right index finger chain", 27, "215-216"),
                R(215, 214, "RIGHT_INDEX_FINGER_DISTAL", "right index finger chain", 30, "216"),
                R(216, 215, "RIGHT_INDEX_FINGER_TIP", "right index finger chain; terminal tip", 0, "none"),
                R(217, 206, "RIGHT_MIDDLE_FINGER_ROOT", "right middle finger chain", 0, "218-221"),
                R(218, 217, "RIGHT_MIDDLE_FINGER_PROXIMAL", "right middle finger chain", 32, "219-221"),
                R(219, 218, "RIGHT_MIDDLE_FINGER_MIDDLE", "right middle finger chain", 28, "220-221"),
                R(220, 219, "RIGHT_MIDDLE_FINGER_DISTAL", "right middle finger chain", 31, "221"),
                R(221, 220, "RIGHT_MIDDLE_FINGER_TIP", "right middle finger chain; terminal tip", 0, "none"),
                R(222, 206, "RIGHT_RING_FINGER_ROOT", "right ring finger chain", 0, "223-226"),
                R(223, 222, "RIGHT_RING_FINGER_PROXIMAL", "right ring finger chain", 35, "224-226"),
                R(224, 223, "RIGHT_RING_FINGER_MIDDLE", "right ring finger chain", 27, "225-226"),
                R(225, 224, "RIGHT_RING_FINGER_DISTAL", "right ring finger chain", 28, "226"),
                R(226, 225, "RIGHT_RING_FINGER_TIP", "right ring finger chain; terminal tip", 0, "none"),
                R(227, 206, "RIGHT_PINKY_ROOT", "right pinky chain", 0, "228-231"),
                R(228, 227, "RIGHT_PINKY_PROXIMAL", "right pinky chain", 31, "229-231"),
                R(229, 228, "RIGHT_PINKY_MIDDLE", "right pinky chain", 29, "230-231"),
                R(230, 229, "RIGHT_PINKY_DISTAL", "right pinky chain", 27, "231"),
                R(231, 230, "RIGHT_PINKY_TIP", "right pinky chain; terminal tip", 0, "none"),
                R(232, 198, "RIGHT_ARM_ACCESSORY_STRIP_1_01", "RIGHT arm/sleeve accessory strip 1", 0, "233-235"),
                R(233, 232, "RIGHT_ARM_ACCESSORY_STRIP_1_02", "RIGHT arm/sleeve accessory strip 1", 9, "234-235"),
                R(234, 233, "RIGHT_ARM_ACCESSORY_STRIP_1_03", "RIGHT arm/sleeve accessory strip 1", 18, "235"),
                R(235, 234, "RIGHT_ARM_ACCESSORY_STRIP_1_04", "RIGHT arm/sleeve accessory strip 1", 0, "none"),
                R(236, 198, "RIGHT_ARM_ACCESSORY_STRIP_2_01", "RIGHT arm/sleeve accessory strip 2", 0, "237-239"),
                R(237, 236, "RIGHT_ARM_ACCESSORY_STRIP_2_02", "RIGHT arm/sleeve accessory strip 2", 5, "238-239"),
                R(238, 237, "RIGHT_ARM_ACCESSORY_STRIP_2_03", "RIGHT arm/sleeve accessory strip 2", 9, "239"),
                R(239, 238, "RIGHT_ARM_ACCESSORY_STRIP_2_04", "RIGHT arm/sleeve accessory strip 2", 0, "none"),
                R(240, 198, "RIGHT_ARM_ACCESSORY_STRIP_3_01", "RIGHT arm/sleeve accessory strip 3", 0, "241-243"),
                R(241, 240, "RIGHT_ARM_ACCESSORY_STRIP_3_02", "RIGHT arm/sleeve accessory strip 3", 13, "242-243"),
                R(242, 241, "RIGHT_ARM_ACCESSORY_STRIP_3_03", "RIGHT arm/sleeve accessory strip 3", 19, "243"),
                R(243, 242, "RIGHT_ARM_ACCESSORY_STRIP_3_04", "RIGHT arm/sleeve accessory strip 3", 0, "none"),
                R(244, 198, "RIGHT_ARM_ACCESSORY_STRIP_4_01", "RIGHT arm/sleeve accessory strip 4", 0, "245-247"),
                R(245, 244, "RIGHT_ARM_ACCESSORY_STRIP_4_02", "RIGHT arm/sleeve accessory strip 4", 7, "246-247"),
                R(246, 245, "RIGHT_ARM_ACCESSORY_STRIP_4_03", "RIGHT arm/sleeve accessory strip 4", 7, "247"),
                R(247, 246, "RIGHT_ARM_ACCESSORY_STRIP_4_04", "RIGHT arm/sleeve accessory strip 4", 0, "none"),
            },
        },
        {
            name = "Waist clothing straps",
            affected = "Four right and four left independently adjustable waist clothing straps",
            joints = {
                R(248, 71, "RIGHT_WAIST_STRAP_1_ROOT", "right waist clothing strap 1", 0, "249-251"),
                R(249, 248, "RIGHT_WAIST_STRAP_1_DEFORM_A", "right waist clothing strap 1, first weighted segment onward", 10, "250-251"),
                R(250, 249, "RIGHT_WAIST_STRAP_1_DEFORM_B", "right waist clothing strap 1, outer segment and tip", 6, "251"),
                R(251, 250, "RIGHT_WAIST_STRAP_1_TIP", "right waist clothing strap 1 endpoint; no child geometry", 0, "none"),
                R(252, 71, "RIGHT_WAIST_STRAP_2_ROOT", "right waist clothing strap 2", 0, "253-255"),
                R(253, 252, "RIGHT_WAIST_STRAP_2_DEFORM_A", "right waist clothing strap 2, first weighted segment onward", 11, "254-255"),
                R(254, 253, "RIGHT_WAIST_STRAP_2_DEFORM_B", "right waist clothing strap 2, outer segment and tip", 10, "255"),
                R(255, 254, "RIGHT_WAIST_STRAP_2_TIP", "right waist clothing strap 2 endpoint; no child geometry", 0, "none"),
                R(256, 71, "RIGHT_WAIST_STRAP_3_ROOT", "right waist clothing strap 3", 0, "257-259"),
                R(257, 256, "RIGHT_WAIST_STRAP_3_DEFORM_A", "right waist clothing strap 3, first weighted segment onward", 10, "258-259"),
                R(258, 257, "RIGHT_WAIST_STRAP_3_DEFORM_B", "right waist clothing strap 3, outer segment and tip", 8, "259"),
                R(259, 258, "RIGHT_WAIST_STRAP_3_TIP", "right waist clothing strap 3 endpoint; no child geometry", 0, "none"),
                R(260, 71, "RIGHT_WAIST_STRAP_4_ROOT", "right waist clothing strap 4", 0, "261-263"),
                R(261, 260, "RIGHT_WAIST_STRAP_4_DEFORM_A", "right waist clothing strap 4, first weighted segment onward", 11, "262-263"),
                R(262, 261, "RIGHT_WAIST_STRAP_4_DEFORM_B", "right waist clothing strap 4, outer segment and tip", 10, "263"),
                R(263, 262, "RIGHT_WAIST_STRAP_4_TIP", "right waist clothing strap 4 endpoint; no child geometry", 0, "none"),
                R(264, 71, "LEFT_WAIST_STRAP_1_ROOT", "left waist clothing strap 1", 0, "265-267"),
                R(265, 264, "LEFT_WAIST_STRAP_1_DEFORM_A", "left waist clothing strap 1, first weighted segment onward", 9, "266-267"),
                R(266, 265, "LEFT_WAIST_STRAP_1_DEFORM_B", "left waist clothing strap 1, outer segment and tip", 5, "267"),
                R(267, 266, "LEFT_WAIST_STRAP_1_TIP", "left waist clothing strap 1 endpoint; no child geometry", 0, "none"),
                R(268, 71, "LEFT_WAIST_STRAP_2_ROOT", "left waist clothing strap 2", 0, "269-271"),
                R(269, 268, "LEFT_WAIST_STRAP_2_DEFORM_A", "left waist clothing strap 2, first weighted segment onward", 11, "270-271"),
                R(270, 269, "LEFT_WAIST_STRAP_2_DEFORM_B", "left waist clothing strap 2, outer segment and tip", 10, "271"),
                R(271, 270, "LEFT_WAIST_STRAP_2_TIP", "left waist clothing strap 2 endpoint; no child geometry", 0, "none"),
                R(272, 71, "LEFT_WAIST_STRAP_3_ROOT", "left waist clothing strap 3", 0, "273-275"),
                R(273, 272, "LEFT_WAIST_STRAP_3_DEFORM_A", "left waist clothing strap 3, first weighted segment onward", 10, "274-275"),
                R(274, 273, "LEFT_WAIST_STRAP_3_DEFORM_B", "left waist clothing strap 3, outer segment and tip", 9, "275"),
                R(275, 274, "LEFT_WAIST_STRAP_3_TIP", "left waist clothing strap 3 endpoint; no child geometry", 0, "none"),
                R(276, 71, "LEFT_WAIST_STRAP_4_ROOT", "left waist clothing strap 4", 0, "277-279"),
                R(277, 276, "LEFT_WAIST_STRAP_4_DEFORM_A", "left waist clothing strap 4, first weighted segment onward", 11, "278-279"),
                R(278, 277, "LEFT_WAIST_STRAP_4_DEFORM_B", "left waist clothing strap 4, outer segment and tip", 12, "279"),
                R(279, 278, "LEFT_WAIST_STRAP_4_TIP", "left waist clothing strap 4 endpoint; no child geometry", 0, "none"),
            },
        },
        {
            name = "Unweighted left-hand attachment chain",
            affected = "Auxiliary chain with no directly skinned vertices in the supplied FBX",
            joints = {
                R(280, 101, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_ROOT", "Unweighted auxiliary chain attached to the left finger/hand hub", 0, "281-292"),
                R(281, 280, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_01", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "282-292"),
                R(282, 281, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_02", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "283-292"),
                R(283, 282, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_03", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "284-292"),
                R(284, 283, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_04", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "285-292"),
                R(285, 284, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_05", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "286-292"),
                R(286, 285, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_06", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "287-292"),
                R(287, 286, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_07", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "288-292"),
                R(288, 287, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_08", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "289-292"),
                R(289, 288, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_09", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "290-292"),
                R(290, 289, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_10", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "291-292"),
                R(291, 290, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_11", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "292"),
                R(292, 291, "LEFT_HAND_UNWEIGHTED_ATTACHMENT_12", "Unweighted auxiliary hand-attachment chain; no vertices are directly skinned to these joints", 0, "none"),
            },
        },
    }

-- ========================================================================
-- VERIFIED GAME AND RUNTIME CONSTANTS
-- ========================================================================
local VERSION_MARKER_EPIC_GLOBAL = 0x3B3379
local VERSION_MARKER_STEAM_GLOBAL = 0x3B2271
local VERSION_MARKER_STEAM_JP = 0x3B2221
local VERSION_SIGNATURE = 0x7265737563697065

local SORA_POINTER_EPIC_GLOBAL = 0x2538A10
local SORA_POINTER_STEAM = 0x2537E48
local POINTER_BANK_TABLE_STEAM = 0x2EE3980

local ROOT_SCALE_X_OFFSET = 0x40
local ROOT_SCALE_Y_OFFSET = 0x44
local ROOT_SCALE_Z_OFFSET = 0x48

-- Verified in the supplied Steam Global runtime capture.
local SORA_MOBJ_POINTER_OFFSET = 0x154

local MOBJ_MAGIC = 0x4A424F4D
local MOBJ_DATA_SIZE_OFFSET = 0x04
local MOBJ_MODEL_POINTER_OFFSET = 0x20

local MODEL_JOINT_COUNT_OFFSET = 0x00
local MODEL_JOINT_TABLE_POINTER_OFFSET = 0x04
local MODEL_MESH_COUNT_OFFSET = 0x0C

local JOINT_RECORD_SIZE = 0x30
local JOINT_SCALE_X_OFFSET = 0x00
local JOINT_SCALE_Y_OFFSET = 0x04
local JOINT_SCALE_Z_OFFSET = 0x08
local JOINT_INDEX_OFFSET = 0x0C

local COMPRESSED_POINTER_BANK_COUNT = 64
local VALIDATION_INTERVAL_TICKS = 120
local FAILURE_MESSAGE_INTERVAL_TICKS = 600

-- ========================================================================
-- RUNTIME STATE
-- ========================================================================
local gameVersion = nil
local soraPointerAddress = nil
local pointerBankTable = nil
local regionalScalingSupported = false
local installationAnnounced = false

local currentSora = 0
local locatedMobj = 0
local locatedModel = 0
local locatedJointTable = 0
local locatedJointCount = 0
local tick = 0
local lastFailureMessageTick = -FAILURE_MESSAGE_INTERVAL_TICKS
local invalidSettingWarnings = {}
local activeRegions = {}
local regionWriteState = {}

-- ========================================================================
-- SAFE MEMORY HELPERS
-- ========================================================================
local function unsigned32(value)
    if value == nil then
        return 0
    end
    if value < 0 then
        return value + 4294967296
    end
    return value
end

local function safeReadLong(address, absolute)
    local ok, value = pcall(ReadLong, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadInt(address, absolute)
    local ok, value = pcall(ReadInt, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeReadFloat(address, absolute)
    local ok, value = pcall(ReadFloat, address, absolute)
    if not ok or value == nil then
        return nil
    end
    return value
end

local function safeWriteFloat(address, value, absolute)
    return pcall(WriteFloat, address, value, absolute)
end

local function plausibleRuntimeAddress(address)
    return address ~= nil
        and address >= 0x10000
        and address < 0x0000800000000000
        and address % 4 == 0
end

local function validScale(value)
    return type(value) == "number"
        and value == value
        and value >= 0.01
        and value <= 20.00
end

local function floatClose(a, b)
    return type(a) == "number"
        and type(b) == "number"
        and math.abs(a - b) <= 0.0001
end

local function normalizedScale(value, label)
    if validScale(value) then
        return value
    end
    if not invalidSettingWarnings[label] then
        invalidSettingWarnings[label] = true
        ConsolePrint(string.format(
            "[ModelProportionScalerV7] Invalid %s scale; using 1.00.",
            label
        ))
    end
    return 1.00
end

local function resolveCompressedPointer(encoded)
    local value = unsigned32(encoded)
    if value == 0 then
        return 0
    end
    if value < 0x80000000 then
        if plausibleRuntimeAddress(value) then
            return value
        end
        return 0
    end
    if pointerBankTable == nil then
        return 0
    end

    local payload = value - 0x80000000
    local bankIndex = math.floor(payload / 0x2000000)
    local bankOffset = payload % 0x2000000
    if bankIndex < 0 or bankIndex >= COMPRESSED_POINTER_BANK_COUNT then
        return 0
    end

    local bankBase = safeReadLong(pointerBankTable + bankIndex * 8, false)
    if not plausibleRuntimeAddress(bankBase) then
        return 0
    end

    local resolved = bankBase + bankOffset
    if not plausibleRuntimeAddress(resolved) then
        return 0
    end
    return resolved
end

-- ========================================================================
-- GAME VERSION AND SORA POINTER
-- ========================================================================
local function markerMatches(address)
    return safeReadLong(address, false) == VERSION_SIGNATURE
end

local function detectGameVersion()
    if markerMatches(VERSION_MARKER_STEAM_GLOBAL) then
        gameVersion = "Steam Global"
        soraPointerAddress = SORA_POINTER_STEAM
        pointerBankTable = POINTER_BANK_TABLE_STEAM
        regionalScalingSupported = true
    elseif markerMatches(VERSION_MARKER_STEAM_JP) then
        gameVersion = "Steam JP"
        soraPointerAddress = SORA_POINTER_STEAM
        pointerBankTable = POINTER_BANK_TABLE_STEAM
        regionalScalingSupported = true
    elseif markerMatches(VERSION_MARKER_EPIC_GLOBAL) then
        gameVersion = "Epic Global"
        soraPointerAddress = SORA_POINTER_EPIC_GLOBAL
        pointerBankTable = nil
        regionalScalingSupported = false
    else
        return false
    end

    if not installationAnnounced then
        installationAnnounced = true
        ConsolePrint(string.format(
            "[ModelProportionScalerV7] READY: %s detected; whole-model scaling active.",
            gameVersion
        ))
        if regionalScalingSupported then
            ConsolePrint(
                "[ModelProportionScalerV7] Using verified Sora+0x154 runtime MOBJ path for MY_SCALE_CONTROLS."
            )
        else
            ConsolePrint(
                "[ModelProportionScalerV7] Epic regional scaling is disabled; its pointer-bank table is not verified."
            )
        end
    end
    return true
end

local function readSora()
    if soraPointerAddress == nil then
        return 0
    end
    local sora = safeReadLong(soraPointerAddress, false)
    if not plausibleRuntimeAddress(sora) then
        return 0
    end
    return sora
end

-- ========================================================================
-- RELOCATED RUNTIME MOBJ VALIDATION
-- ========================================================================
local function validateRuntimeMobj(mobj)
    if not plausibleRuntimeAddress(mobj)
        or safeReadInt(mobj, true) ~= MOBJ_MAGIC
    then
        return nil
    end

    local dataSize = safeReadInt(mobj + MOBJ_DATA_SIZE_OFFSET, true)
    if dataSize == nil or dataSize < 0x1000 or dataSize > 0x2000000 then
        return nil
    end

    local modelEncoded = safeReadInt(
        mobj + MOBJ_MODEL_POINTER_OFFSET,
        true
    )
    local model = resolveCompressedPointer(modelEncoded)
    if model == 0 or model < mobj or model >= mobj + dataSize then
        return nil
    end

    local jointCount = safeReadInt(model + MODEL_JOINT_COUNT_OFFSET, true)
    local meshCount = safeReadInt(model + MODEL_MESH_COUNT_OFFSET, true)
    if jointCount == nil or meshCount == nil
        or jointCount < 1 or jointCount > 1024
        or meshCount < 1 or meshCount > 256
        or jointCount ~= SETTINGS.EXPECTED_JOINT_COUNT
    then
        return nil
    end

    local jointTableEncoded = safeReadInt(
        model + MODEL_JOINT_TABLE_POINTER_OFFSET,
        true
    )
    local jointTable = resolveCompressedPointer(jointTableEncoded)
    if jointTable == 0
        or jointTable < mobj
        or jointTable + jointCount * JOINT_RECORD_SIZE > mobj + dataSize
    then
        return nil
    end

    -- Confirm the relocated table shape before any named-joint write is allowed.
    for joint = 0, 2 do
        local record = jointTable + joint * JOINT_RECORD_SIZE
        local storedIndex = safeReadInt(record + JOINT_INDEX_OFFSET, true)
        local scaleX = safeReadFloat(record + JOINT_SCALE_X_OFFSET, true)
        if storedIndex ~= joint or not validScale(scaleX) then
            return nil
        end
    end

    return model, jointTable, jointCount, meshCount
end

local function clearLocatedModel(sora)
    currentSora = sora or 0
    locatedMobj = 0
    locatedModel = 0
    locatedJointTable = 0
    locatedJointCount = 0
    activeRegions = {}
    regionWriteState = {}
end

local function buildActiveRegions(jointTable, jointCount)
    local configuredBase = SETTINGS.BLENDER_INDEX_BASE
    if configuredBase ~= 0 and configuredBase ~= 1 then
        ConsolePrint("[ModelProportionScalerV7] BLENDER_INDEX_BASE must be 0 or 1; using 0.")
        configuredBase = 0
    end

    local referenceByJoint = {}
    local parentByJoint = {}
    for _, group in ipairs(JOINT_REFERENCE) do
        for _, reference in ipairs(group.joints) do
            referenceByJoint[reference.joint] = {
                group = group,
                joint = reference,
            }
            parentByJoint[reference.joint] = reference.parent
        end
    end

    local accepted = {}
    local acceptedByJoint = {}
    for controlNumber, control in ipairs(SETTINGS.MY_SCALE_CONTROLS or {}) do
        if control.enabled then
            local blenderJoint = control.joint
            local runtimeJoint = nil
            if type(blenderJoint) == "number" and blenderJoint % 1 == 0 then
                runtimeJoint = blenderJoint - configuredBase
            end

            local fallbackName = "Control " .. tostring(controlNumber)
            local controlName = tostring(control.label or fallbackName)
            if runtimeJoint == nil or runtimeJoint < 0 or runtimeJoint >= jointCount then
                ConsolePrint(string.format(
                    "[ModelProportionScalerV7] REJECTED %s: joint %s is outside the %d-joint model.",
                    controlName, tostring(blenderJoint), jointCount
                ))
            elseif acceptedByJoint[runtimeJoint] ~= nil then
                ConsolePrint(string.format(
                    "[ModelProportionScalerV7] REJECTED %s: joint %d is already enabled by %s.",
                    controlName, runtimeJoint, acceptedByJoint[runtimeJoint].name
                ))
            else
                local metadata = referenceByJoint[runtimeJoint]
                if metadata == nil then
                    ConsolePrint(string.format(
                        "[ModelProportionScalerV7] REJECTED %s: joint %d is missing from JOINT_REFERENCE.",
                        controlName, runtimeJoint
                    ))
                else
                    local record = jointTable + runtimeJoint * JOINT_RECORD_SIZE
                    local storedIndex = safeReadInt(record + JOINT_INDEX_OFFSET, true)
                    if storedIndex ~= runtimeJoint then
                        ConsolePrint(string.format(
                            "[ModelProportionScalerV7] REJECTED %s: joint-table record %d stores index %s.",
                            controlName, runtimeJoint, tostring(storedIndex)
                        ))
                    else
                        local reference = metadata.joint
                        local active = {
                            name = controlName,
                            config = control,
                            reference = reference,
                            blenderJoint = blenderJoint,
                            joint = runtimeJoint,
                            record = record,
                            group = metadata.group.name,
                        }
                        accepted[#accepted + 1] = active
                        acceptedByJoint[runtimeJoint] = active
                        ConsolePrint(string.format(
                            "[ModelProportionScalerV7] CONTROL ACCEPTED: %s joint=%d reference=%s parent=%s children=%s.",
                            controlName,
                            runtimeJoint,
                            tostring(reference.name),
                            tostring(reference.parent),
                            tostring(reference.descendants)
                        ))
                    end
                end
            end
        end
    end

    if SETTINGS.WARN_OVERLAPPING_ENABLED_JOINTS then
        for _, active in ipairs(accepted) do
            local ancestor = parentByJoint[active.joint]
            while ancestor ~= nil do
                local enabledAncestor = acceptedByJoint[ancestor]
                if enabledAncestor ~= nil then
                    ConsolePrint(string.format(
                        "[ModelProportionScalerV7] OVERLAP WARNING: enabled parent %s (joint %d) also affects enabled child %s (joint %d); scales may compound.",
                        enabledAncestor.name, ancestor, active.name, active.joint
                    ))
                    break
                end
                ancestor = parentByJoint[ancestor]
            end
        end
    end

    if #accepted == 0 then
        ConsolePrint("[ModelProportionScalerV7] No MY_SCALE_CONTROLS rows are enabled; only whole-model scaling will be applied.")
    end
    return accepted
end

local function locateRuntimeSkeleton(sora, announceFailure)
    clearLocatedModel(sora)

    local encoded = safeReadInt(sora + SORA_MOBJ_POINTER_OFFSET, true)
    local mobj = resolveCompressedPointer(encoded)
    local model, jointTable, jointCount, meshCount = validateRuntimeMobj(mobj)
    if model == nil then
        if announceFailure
            and tick - lastFailureMessageTick >= FAILURE_MESSAGE_INTERVAL_TICKS
        then
            lastFailureMessageTick = tick
            ConsolePrint(
                "[ModelProportionScalerV7] Sora+0x154 did not validate as the 293-joint MOBJ; regional scaling is waiting."
            )
        end
        return false
    end

    locatedMobj = mobj
    locatedModel = model
    locatedJointTable = jointTable
    locatedJointCount = jointCount
    activeRegions = buildActiveRegions(jointTable, jointCount)
    ConsolePrint(string.format(
        "[ModelProportionScalerV7] MDLS FOUND: Sora+0x154 -> MOBJ=0x%X model=0x%X joints=%d meshes=%d; easy-table joint scaling active.",
        locatedMobj,
        locatedModel,
        locatedJointCount,
        meshCount
    ))
    return true
end

local function locatedSkeletonStillValid(sora)
    if locatedMobj == 0 or sora ~= currentSora then
        return false
    end
    local encoded = safeReadInt(sora + SORA_MOBJ_POINTER_OFFSET, true)
    if resolveCompressedPointer(encoded) ~= locatedMobj then
        return false
    end
    local model, jointTable, jointCount = validateRuntimeMobj(locatedMobj)
    return model == locatedModel
        and jointTable == locatedJointTable
        and jointCount == locatedJointCount
end

-- ========================================================================
-- SCALE WRITERS
-- ========================================================================
local function applyWholeModelScale(sora)
    local x = normalizedScale(SETTINGS.WHOLE_MODEL.X, "WHOLE_MODEL.X")
    local y = normalizedScale(SETTINGS.WHOLE_MODEL.Y, "WHOLE_MODEL.Y")
    local z = normalizedScale(SETTINGS.WHOLE_MODEL.Z, "WHOLE_MODEL.Z")
    safeWriteFloat(sora + ROOT_SCALE_X_OFFSET, x, true)
    safeWriteFloat(sora + ROOT_SCALE_Y_OFFSET, y, true)
    safeWriteFloat(sora + ROOT_SCALE_Z_OFFSET, z, true)
end

local function applyRegionScales()
    if locatedJointTable == 0 then
        return
    end

    for _, active in ipairs(activeRegions) do
        local region = active.config
        local regionName = active.name
        local record = active.record
        local x = normalizedScale(region.X, regionName .. ".X")
        local y = normalizedScale(region.Y, regionName .. ".Y")
        local z = normalizedScale(region.Z, regionName .. ".Z")
        local state = regionWriteState[regionName]

        if SETTINGS.VERIFY_JOINT_WRITES and state ~= nil
            and not state.persistenceReported
        then
            local beforeX = safeReadFloat(record + JOINT_SCALE_X_OFFSET, true)
            local beforeY = safeReadFloat(record + JOINT_SCALE_Y_OFFSET, true)
            local beforeZ = safeReadFloat(record + JOINT_SCALE_Z_OFFSET, true)
            state.ticksAfterWrite = state.ticksAfterWrite + 1
            local persisted = floatClose(beforeX, state.x)
                and floatClose(beforeY, state.y)
                and floatClose(beforeZ, state.z)
            if not persisted then
                state.persistenceReported = true
                ConsolePrint(string.format(
                    "[ModelProportionScalerV7] ENGINE OVERWRITE: %s joint=%d changed before the next Lua write; the animated pose is replacing MDLS scale.",
                    regionName,
                    active.joint
                ))
            elseif state.ticksAfterWrite >= SETTINGS.VERIFY_STABLE_AFTER_TICKS then
                state.persistenceReported = true
                ConsolePrint(string.format(
                    "[ModelProportionScalerV7] PERSISTENCE OK: %s joint=%d retained (%.3f, %.3f, %.3f) across engine ticks.",
                    regionName,
                    active.joint,
                    x,
                    y,
                    z
                ))
            end
        end

        local okX = safeWriteFloat(record + JOINT_SCALE_X_OFFSET, x, true)
        local okY = safeWriteFloat(record + JOINT_SCALE_Y_OFFSET, y, true)
        local okZ = safeWriteFloat(record + JOINT_SCALE_Z_OFFSET, z, true)

        if state == nil then
            local readX = safeReadFloat(record + JOINT_SCALE_X_OFFSET, true)
            local readY = safeReadFloat(record + JOINT_SCALE_Y_OFFSET, true)
            local readZ = safeReadFloat(record + JOINT_SCALE_Z_OFFSET, true)
            local immediateMatch = okX and okY and okZ
                and floatClose(readX, x)
                and floatClose(readY, y)
                and floatClose(readZ, z)
            state = {
                x = x,
                y = y,
                z = z,
                ticksAfterWrite = 0,
                persistenceReported = not SETTINGS.VERIFY_JOINT_WRITES,
            }
            regionWriteState[regionName] = state
            if immediateMatch then
                ConsolePrint(string.format(
                    "[ModelProportionScalerV7] WRITE READBACK OK: %s joint=%d scale=(%.3f, %.3f, %.3f).",
                    regionName,
                    active.joint,
                    x,
                    y,
                    z
                ))
            else
                state.persistenceReported = true
                ConsolePrint(string.format(
                    "[ModelProportionScalerV7] WRITE READBACK FAILED: %s joint=%d requested=(%.3f, %.3f, %.3f) read=(%s, %s, %s).",
                    regionName,
                    active.joint,
                    x,
                    y,
                    z,
                    tostring(readX),
                    tostring(readY),
                    tostring(readZ)
                ))
            end
        end
    end
end

-- ========================================================================
-- LUABACKEND CALLBACKS
-- ========================================================================
function _OnInit()
    if ENGINE_TYPE == "BACKEND" then
        gameVersion = nil
        soraPointerAddress = nil
        pointerBankTable = nil
        regionalScalingSupported = false
        installationAnnounced = false
        tick = 0
        lastFailureMessageTick = -FAILURE_MESSAGE_INTERVAL_TICKS
        invalidSettingWarnings = {}
        activeRegions = {}
        regionWriteState = {}
        clearLocatedModel(0)
        detectGameVersion()
    end
end

function _OnFrame()
    tick = tick + 1

    if gameVersion == nil and not detectGameVersion() then
        return
    end

    local sora = readSora()
    if sora == 0 then
        if currentSora ~= 0 then
            clearLocatedModel(0)
        end
        return
    end

    applyWholeModelScale(sora)
    if not regionalScalingSupported then
        return
    end

    if sora ~= currentSora then
        locateRuntimeSkeleton(sora, true)
    elseif locatedMobj == 0 then
        locateRuntimeSkeleton(sora, true)
    elseif tick % VALIDATION_INTERVAL_TICKS == 0
        and not locatedSkeletonStillValid(sora)
    then
        ConsolePrint(
            "[ModelProportionScalerV7] Sora model changed or unloaded; resolving the verified path again."
        )
        locateRuntimeSkeleton(sora, true)
    end

    applyRegionScales()
end
