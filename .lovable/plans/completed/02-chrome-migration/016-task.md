---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section16"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/08-file-folder-naming/bash.md"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/bash.md"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "spec/21-app/fixtures/chrome-profile-export.example.json"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a — no db"
  ui_surface: "n/a — cli"
  tests: "unit test-16"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 016 — Importer Preflight (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for ImporterPreflight(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Check dependencies (jq, sqlite3). Print install command if missing. 2ee68323-9f71-48a3-ad99-5adbd2728f7e 22ead3de-ea30-4460-9ed2-29c9f43cac03 105f9f23-5f8e-4d2f-b292-79478eab1e66 81ba36d7-c60e-4b33-b622-abc518dfaf1b a1919422-fa56-416e-82b7-e1083ff9f893 76c683db-7915-43df-ac24-3864ddb36566 394f1b64-869f-4a70-b5b5-8b38a9f8968e 732f7022-ae1c-4565-9926-7eff73bc5c8c b2d4e784-a750-4a14-bdf6-749a1141c010 97ddd755-b7f0-4d63-9afc-960dc620e6ee 47f74855-8783-4767-9263-55a7ce689d09 31868551-75cc-417e-80bc-17d07727f01d bb23d926-1ded-46d2-9f66-4feaba4246cc 87fa76de-0c7b-4132-9da6-4fe187cd2d22 4a639cbb-c8c6-414f-97dd-be28319b7705 0e525066-8fff-4827-9282-dc9cfb746103 cc2875a5-c04f-496d-9e4f-6509e1dc9910 def072d0-8a04-4c6d-bf14-ba377193ec56 9ebd42c9-0673-48a1-8d09-fb7fa419be59 46206ead-9424-4bdf-a636-8ec342ecf85b e9963b06-2e5e-4475-b68a-9aae033a5055 c07136f6-a291-4cd6-b5ea-da2034d022d6 ae222dd1-cbf8-4ac1-9a41-ec26bab0d432 527632ba-c298-4f5e-9fbf-480d2e6a74ea 23d303fb-0fa8-4056-903c-6c88b56d1ce5 7e77e4f0-fa81-46f5-bd2e-c289aff7f17a e3cb698c-aec3-449d-87c2-34f15a9f09bb 1303032a-4750-4c62-a1bf-5f55ff72d5ba 3d8d89d2-39fd-49c7-b07f-a53ed6af8b01 7a742ded-316b-4898-93df-572335266d95 3e2d457c-9775-43d3-8929-39dbc538c675 1398bc00-fb65-4cd6-8b18-036a0320a7d6 be13228c-aa0d-4f49-b5ce-93a362ea5c37 7b3d8039-7e7d-4db6-b9e5-cc12ad8b72fa 79f10ccf-6ad4-4f4c-879f-6f732a6d2fc8 aa7845f8-3849-4fa9-82b0-8f55875fe147 68b89a35-192c-4b1c-9313-d22c29e47cf9 19eb58b6-a5cc-4ae7-818b-47a6d8735b40 64d78e0c-461f-4c19-9a54-c041132e34e8 ab22b8d0-e408-4ac0-b3d1-51e1c352ff56 38dcb832-22e9-4851-a852-201af5c2d808 aea349f1-fc54-4e0d-9ed3-9bcba55345e0 93031aa6-7841-4a90-a121-b363c7ec6dcd fdcca1b7-5acf-449a-8539-2757eeb10973 62e1b251-cefb-4c9e-b291-94c6f0187293 b4ed02df-3313-4c0c-8c7f-b0800160c8c9 ee237904-836f-4849-a09f-55bf799105b6 241303e9-0c0c-47bd-83ba-bd546e53e468 a084e8fc-a127-431f-be92-b7c8a1b4d8d2 1425c7c1-4227-49e2-af3d-1852f4380a05 3ff80975-c40e-4b1e-88fb-16e90caae1e5 a3bfc290-36c3-4b6b-88fb-53e722bd4bdb dfc6308e-6339-4fa1-afb9-3839f40e8f3c 9559e8a4-9dec-4237-b2de-064f9aab4308 bb2f601d-e68b-4b62-a5e7-bbb3df29ff42 50461c22-e1c5-47b6-9f15-dda78a580240 13d53183-0174-4eca-a495-56c6c436d73a 1922701b-ca72-49da-aaca-47631902db5e a1eb6c8e-c70b-4e31-bfb8-d3e7b463cded 607031b8-a6c6-484f-9573-f6d5910a2c72 4ca08e82-ae50-4e1b-9416-31a101e0bbe8 7ed0acb1-84eb-44d3-9f9e-f9c48b484c86 6f79f39d-cb1f-4903-93cf-84c74e46654c 1d7997eb-96fb-41f0-910c-c1ee119ad082 d467aa14-f199-4f39-aa40-44f53258856d 201b7696-7d0c-4014-a33d-3e60b7fb0d37 06947679-a3ab-4bcc-b62a-de0fa169a60d b043f7b2-f58d-48f0-abcc-7d47480ae9d0 58498f9a-8a4a-4549-b4db-30f5a77100bf f071926a-29d0-45b6-9848-e2ccc1421f35 cd5a9a50-349f-4c75-8ab0-09e73691820b 7d3f5301-b055-4eec-99cf-e11260f51301 87aca2cd-50af-49ac-9241-39ecb21bcc07 cdaf7ddb-8e58-4ffd-94c4-a57bdeed45b1 3f675ccf-ec0b-4b28-992e-de204846c6f9 fea42197-72a6-40dc-9743-2f2fc2c1ba87 d0afdaed-1758-4bee-9902-a1a0e805151a 92d23de0-4691-4e3c-b1cb-2595ef28b26f b888ec33-3e33-470f-8c58-6db27d0a8d8d d74b8195-9bdc-46eb-b274-e7de9237a7a8 9cfb078b-cc30-4391-a00c-b256e4a2c236 be7fe74b-61a3-4556-83f6-39719dc2f19c 0e719494-0441-48db-a26a-1bc5d9162eea f5ba9169-7b35-4eec-ba7e-6bd0f8b3e5db 55c93fe6-260e-4e31-8c13-3f4f791c62d4 60e8bed8-9289-4674-b267-639ddaf124c5 4c78af99-3719-4174-94df-3559675c1578 4de3bad3-c3f4-40cf-97e4-61a476b8914b 969c8a25-13de-4501-b993-4d07207dc1a5 6791840c-21b6-41a8-8c30-5d938d8857f2 3fb2db0a-0add-4133-b2c0-eae9fee176b9 5e2e16a7-ffea-4b15-b92b-0553fd8a77ea 2ea0baba-c27f-4a26-a311-3e3d45d65162 ac5688c2-a4b9-473c-8772-a46a98005868 21d10132-668f-4d49-8af9-c8b32147aa98 c5cd6442-8217-4d77-a494-7fbfa3aed668 ce727ce3-e73f-4aa4-a94e-4724ff25274d c5f95a55-a8ae-4164-88fe-a7aa46d01865 e1565f05-132f-4f58-9130-add0f9772990 e6b0d916-7934-49e0-a8c1-44437673ee06 ee89ce40-807a-4b65-a79f-75f1fb4a3e39 14312720-af86-48be-a17a-385a0a4e6ad1 18df4daf-25fe-4d68-94ff-c5ac121fb93b 66efafdd-ef8a-4ed5-860b-d1636ec24646 11018eed-be3d-45cf-af4b-0dd3e8ddd673 be0ecb22-a0b7-4f4e-8743-b3d2977dbb9a 881fbfcd-2830-4615-aba1-0bc0ce414148 25d1f27f-ec3f-40c6-b16d-dc32fa33bf4a 0f6d7663-a83c-44c3-8d8d-4eabf2e19372 a21dd0c5-e49f-48d2-82b5-ab0b78510435 5752ae61-5de4-451c-aa30-58f6268da7f8 204b96f1-7b85-4561-b4e1-5e7105307938 124cc60f-98fc-40a9-9b9a-6f6bae0ab755 35bb2764-6086-44dc-8b6f-0bc5d67bd39a f5683f7f-bb33-45df-be50-32940820da97 706724b5-129d-46bb-8f16-beb88da55692 f944b197-1d33-4527-8477-9399ed7c57b0 a1230000-d68f-482b-8aee-14efeeb1d6c1 8f218ae7-6449-4465-9599-cf92f80aa0d5 efd40e7b-c9db-495c-9be5-0ef053a9bb6f 3fd8df22-5770-4ead-a2b1-d109a519663e b7bae50c-160f-43f3-8e1f-65d5f3e42509 19ca9de0-42ed-4c25-a3c4-732ae2db1f75 9467aa0e-b6b7-492e-9894-217020306c7e 2d31593e-dfbf-4d55-a788-c25461b1cc8c 5f045476-e1c2-4c4a-8a3b-c9e5e510a9a0 1a26d6ac-4ff5-4a5e-af73-67a1de7bcc54 9f450e75-00bf-4c25-915a-5d81563c3e24 68d3bb79-9415-4755-a440-0fccb166e0e7 427b9117-147b-42ed-957f-bcaf4da45c30 ab1093b9-1364-4a8e-96d2-16f93e3d596d 73ab9c8d-b62f-4b8b-b91f-6066619737e1 6089a139-b457-499b-ac41-3870e30d51cd f05064ca-77fc-4d71-9b39-ccad6c29bc1b 354182e2-c931-48e8-9c22-b51388625972 504df785-3337-4fa4-8a6d-eb246c9b9ccd 17913464-9455-4062-b3a1-75d9eb8251ef 13897bd8-3703-4a00-a79c-41f6b85ac92b 17157d3e-8ea4-4a37-86a6-41e76b349dc5 141a1f0b-a9e6-4fc4-8b95-b188cb16b0a2 eff1220f-9f8c-4090-a9ce-1db7c9ab7638 b401d5b9-a134-4360-8955-7766974c435c 7ae4b812-5cd2-4474-a211-250ed8afa457 51df9970-c2f2-4ef2-9d78-70e80139c759 4bee8685-7b21-4846-affc-a859694a3150 c838c31d-4004-4931-992f-d9cf06caae49 59e460d9-b797-4acd-874b-d15e55d265b4 c05568ed-216e-46c9-b438-5188239c5c06 7e658460-37a1-4a34-99e9-92a72cd2c6f5 ad514bf1-2c31-4e4a-b050-1e2a8714e2f5 9b0d9e94-e656-4df0-9cab-6e9078d751b3 864c39e9-838e-460d-a423-efeea4f25d5b 96795461-1d7e-418f-a96e-8d53bc62440c 9521eb3a-6c5a-4b94-b467-956b41b93e07 bdbbea0b-5830-4b9a-8fb6-b0f93cd79679 9f660ea1-3625-4092-a572-0bab03bfa045 e12cab36-81db-4970-8d00-ccf6b02ffa74 2c1ac7bb-a6d0-4eb1-934d-1b2ac38b82bd 65c4a57c-07af-4b84-a02a-9a58edca353c ea8f47c0-7c06-4225-8159-270e16fe320e bcd906ae-1310-4de4-91bb-6ddbfce539b3 42ea18c7-4955-4d87-aafb-0bfbe0acfbd4 cf8cec1f-3630-4bb3-a778-85853250c7c1 972e7a03-dbfc-473f-9f96-d76c41ecf398 90d03aa0-2451-44c6-9f23-5f9cc4eac2f3 2d99debe-1fa1-45ca-87e5-501aef9eec6a 6862b555-19a3-43c8-bf3a-f70335ccf07b b41a0a56-3bbd-4f04-887c-df03401c04b1 61ce622d-c672-467e-8fa2-3173d5494171 5e00cbf5-c714-4608-bd69-4162b9edaa03 3a8b4bb7-c85c-4db2-91ae-5a749d2a1642 d43cec65-3b0a-46d0-aba8-de5cf9771560 e72ef951-cef3-4e1f-ae33-9f990847ec10 27c14b1e-3bec-4664-bfa8-0893b08de680 2861d343-c99a-4c90-ab71-9a4ecbcf9285 7c8e1bfe-c482-4b83-8b09-3633103087cc fadfef11-eebd-4e42-bc79-9e867d868b18 fef709de-cc2e-494a-bdc8-d4afc131ecc4 64854f6f-8b41-4e54-b049-ae1625ffb8ce 9a353166-5950-45bc-bc1d-7c5afa6a8e9c e12571bd-ba7b-4a42-9ff5-3f7e15325c63 f0271aec-c58b-4984-b4ff-0f57cb1bf4e6 5a511918-6d17-4e1c-9b30-6a60c01850cc 62ed5f96-d8fd-4ae9-a4c7-54dd1a186d69 738e3599-ed8b-463a-9fd9-6fe8c5f853e4 7517f440-b943-4c2a-90b3-09917200ec6e 8a139830-5e99-4bc6-b8fc-84bee4278e2c a4e99d52-2423-465c-a16b-e1966a685724 6d18f48e-dbcb-46dc-a4e3-b6cb7be9f2ea 321700b9-c931-4dc0-87db-19e9b4cd7ab9 2e367d67-4bce-4faa-8e6a-8e77564aa1f7 41dd93e2-2c0f-4d75-8054-037235f6b73f 48624e84-efe8-4863-b5e2-1b35e468e5d0 d2fdfb8e-17d0-4805-b023-95d2a13d2499 865f4e3d-8330-4a6d-b790-96455bb68fb4 ab33286f-984f-44f9-8f6d-9fce165c24c8 cbd74618-98b0-45c1-920b-78e07d9f8bca 6fd2cd65-d664-4952-b252-b8cd521a4da0 957919dc-b876-440d-b7ee-9dfbe6e7905b e406885b-f097-47bf-bbca-4ad6051e4fce 86360760-1b17-457d-bc92-bcbbded82818 1a6ff404-9ede-4db2-b9dd-f983b8a09b82 f243ce17-d853-40fb-ba17-80281a698041 914f0ea4-df50-4d91-8522-a9e5473e60c4 2c2bcf39-8f80-4fab-aa19-b8ec633bcba5 fb65189c-3d5d-426e-a3d4-24f1b81c2ac5 a02e40f0-5744-4c27-af8e-bceda45ff61d f589b75a-4d5b-4e85-aa12-d007c1ae74f4 90019522-7217-44ad-846f-ad3a8a4eef91 b153b35f-514e-4a5a-b687-b9c3b35b2186 f3f47e0a-8f64-4ea1-a2ab-68637b06cd9f 917e4d27-8e18-41ad-a793-515524d638bf c1c1b434-f149-4b75-b876-25591c208aa9 6286517a-27fd-41f2-8d3d-aefa308118aa f4b2cfd6-2726-4f7b-91dd-8e75a034b17d 794efcfc-abcb-4e25-91e0-a1834912c015 7f1f3076-34c2-429c-baae-134c1ae7a208 c52892ed-6a1a-42bd-a28c-f528ded83381 5f1f6100-627f-462f-a8b3-081d24f2ad89 0b79efd7-0b89-461b-b18e-34d21d791813 293d2561-936c-4168-8af3-e218b16d9a81 78eaec02-fde1-4141-ab7d-4483ba57f0a7 2aa0ddb9-f2de-4033-b1d3-e1f40dd36b8f b39a7d56-d187-465c-ab99-96788519a661 7a5a46d4-f3bc-493b-90c6-0d8e40cdc21e 762671bd-39e0-4036-998c-cdbe74c7a075 c58cfef5-7182-469f-b92f-e4a5f536a475 c97b45e9-8b1f-4bce-ae85-050c73ae84bb 8fab1718-d5d8-4e5b-96f5-f0c81d952d7f 0172e558-41b5-4fbe-8c05-e25ed877d6cc 64c1c93d-47f1-4886-bdef-9caa3ddb178b 727fcc2a-08a9-4f14-9cd8-d914d792807b 620a46ea-5c76-440f-b913-f7c1bc72020c 9bff5c33-4a4c-42bd-b1b5-956e703bd19c e5cfc90d-32a6-4b45-98e2-f4e7440f9633 e7b8acbf-e6e8-4eaa-9115-b82d1a67e0bc 353d51c5-af29-4c15-a3c5-32bed2bc4a5b 29565914-d3bb-4fb6-bbdc-34576f374386 05662a22-dd72-4ef6-9e83-70308ede3379 b926df04-3ca6-4f2f-967d-50f804dd1301 bbbe5e11-ac1f-4187-947c-38c4c8232f32 c2689519-6003-4fac-a1ec-dab9c4fe15c3 a3473829-7355-44a5-b88c-01a558c9f105 43993190-a1a0-468c-8c6d-074bc73ac5f4 608cd1e6-9bf8-4f40-9ed9-43b93682caae 7204843d-7e5b-45be-ae83-3de130e8a655 8ae4c5c9-f9b2-4f5e-8ea5-a895bd4bbaa6 fd2f6ff7-da4d-4bb1-9b33-4c8eaad110e5 19413976-cb86-441f-a709-5df4f2dfcb9d e85406da-5d10-4762-b971-5437db761ded

## 3. Inputs and Contracts
Input: Profile metadata for check_dependencies().
Output: Script execution status.

## 4. Execute
- Write check_dependencies() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "check_dependencies()"` or `bash -c "check_dependencies()"` depending on the environment. Expected output: success for ImporterPreflight(SH).

## 7. Done When
- [ ] Criterion 1: check_dependencies() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
