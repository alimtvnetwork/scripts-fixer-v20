---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section21"
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
  tests: "unit test-21"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 021 — Bookmarks Merge (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for BookmarksMerge(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Handle --merge. Dedupe by normalized URL. Assign new ids. 2c5a0faf-a486-49c9-8f88-ba5a9f293f58 8199e4b1-018b-41dc-8163-af6d25697914 1947a03e-9f30-4e8f-a177-35227c164a48 6ac6b376-7b32-4353-98c8-b827883595bc ef9a901e-9e7c-4c0d-95e6-ec0e72da9d4c cc98bd32-e485-4327-91aa-fa15e2cb69c4 5f729e1a-2301-41da-80cc-966cef735101 adf96f63-2550-4125-9ead-9110dfd28769 5b090ffb-54e0-4e23-b6c1-e6913e08cd5f 23151ce5-c107-4201-b49d-680946eeeb71 6247e74d-5d28-4ff0-923b-1d0800d94de5 1c197b13-d82a-486d-9468-193d7d90b2de c116ca4d-725b-49e4-acb4-a611d279621c 819a19e2-4fce-4e25-b199-c8aca63ce61a e3acb26a-a598-4f0e-920b-ae8315e47f81 f3472873-29cf-4ba4-94af-c0fc2d0a1bbf 0218e0e1-eba7-4ddc-beab-fc0bbbbc3d9a 06860a0f-49e7-4e90-838d-dcd29a80eac3 0321b378-996b-46ab-934a-acdab17381d5 1d46abbf-eb55-4bca-a8b4-02fe36135a3f 302bef82-ca9a-4005-b5e6-e6f113498234 5843690d-6fe5-44bf-842e-c78b7a261bc4 391c013a-75d9-441b-a9d8-532c68db278c bf63b2f0-83b3-4862-b691-83add566170f 8ebcbffb-b9b9-4238-9f23-32645c388017 f94c9379-7ef4-43d8-8e26-172478a5a060 b849fedb-2184-4ceb-a11c-736a8f4bfdc8 7d700437-9276-4ebf-bc10-98daeaa9c840 a2ef0203-a3c6-40d1-aa66-65433d9411fd 3698320a-a27a-4aa3-9a8f-8f8b56938a10 c824c395-6e1d-49c2-819e-0cc8da2d9f6e d53e837d-5e1e-4292-84cd-b2ccc19a7065 5a454a26-cefa-4492-b764-3a53a8ca281b 2f079975-14f0-48c0-8a2a-4fb16be80a1e 5e5b5c0d-4163-4e0a-b07e-fc1611fe946d ee2287ff-fb16-45d8-83a9-af576cbc3403 be447c64-8b1d-423f-b1db-b0acd9a93766 de9279f1-3399-47f1-b1fc-d5e4520ad5ef 24df988c-cbf3-4db8-896d-a3a1446a4b92 bb0038fe-a27f-4aa9-8864-1ae69a3a1f8f bc390431-5897-4fd3-990e-c827e931a1d4 feb27d7a-c2f4-4565-8864-9eab87a0d305 72f031c0-314f-4dbf-8c15-5154b610f8a0 42ba5e1c-8104-4f17-8122-45d9940d5c48 addef485-c8e9-40dc-95f8-11d7aa7be4d8 846cda69-c522-45b2-a90e-1c991368b277 c84d8f2a-bcfb-4070-9e7c-1bfa97abce4b 5126f721-c0d1-4bae-9cf4-c954415cff86 db479c53-9ed3-4b60-bd4e-c97f99632078 eebbd68c-517d-49f8-8904-b60b1f59ba43 497e8bab-ffde-485c-ae05-bb063b0d22e3 e3b856e2-d046-40d3-ae8c-7dad760f2556 80e24d08-7468-4a90-a585-ae4198c7184f ea311f38-3083-4c39-a4ef-60724f035d8c 61f5cf8c-23e8-4a9e-b204-817ef5648167 99702522-20b2-4c7f-8caa-7adb85684059 82960171-5cf8-44a8-961e-c1141fc28340 75c30048-c5da-4c95-98d1-225098865a50 394fceb7-ec32-4cb2-aadd-ce28cf6e7f82 7321c756-75a8-4669-b20e-6efc8e4f8e1c 55cc7c39-6863-4c37-9b35-5e0ab54152cc d862e5bf-8828-428b-a778-6612ca380ad5 d4164ec4-3a9c-430e-bddf-8edd164d4b23 feb87a76-be4e-43df-ba25-5e324a3a09e1 8a631fb6-2c6b-4c41-807d-6fbfe76a5116 6ea5850e-a110-4436-96a7-4ad8fd19ff98 d8d9e011-b662-4771-9bd9-48bc63de772f 658f76b4-2db2-4051-ab47-dbef4dc61460 2928066b-1023-4d2f-b6e7-2fdb32803e09 9c4241f4-a13e-4174-927c-7a13759c374b e58e33cb-517b-4f62-8de3-a930f0717466 0abfb072-3f4e-4254-a7e9-ce16e872e403 bce2ba2f-6e75-49d6-9f95-24872e71d7a8 d31e3538-4679-423d-9707-f6dbd082917a 87e98f02-37ca-4dab-83d4-bf832aac82ea 0b778c77-6a0d-4685-857c-b5fa79dbe2ec 9d5bcf0d-0514-45ae-ac1c-c8fdd2029966 35023fd0-3c85-4844-9229-1dfdd6830cb1 48df5f11-1f47-4d1a-8eb4-531721ec81a0 9484e912-37e3-4528-a8d2-2e40648ae6cd b6bd5bc2-bc80-45ac-b65a-be0c3404402c e51ef1a3-3faa-4b34-8f2d-570dc4d8a565 7297e327-e24c-41a8-9ee7-8203987eea7c 7f6424d8-b58b-4778-aabb-2132a0de7e2d 3f703353-27c7-48b8-a555-ae2d35c6f22a 211b1b02-8c86-4c80-ad80-ee20ba8d0797 38766022-1cfd-4055-bac7-98650185be6a 8dab48c5-836a-4886-a590-8e95314faa12 bfafbe81-c917-4d79-97ab-c479caefe077 7b0f74ec-6d59-443a-a00e-e176710c0976 4ab3a462-6b65-4a46-b6f4-6516d7aa51de b224ca9a-b06c-4bc7-b99b-fc4fe5e5d777 5ff8eb48-56fe-4b2e-9832-1c51de8c4802 23a721da-ab9f-40f2-a075-29709c3d2c32 6133626a-9c47-45a9-87be-47361ff47d27 c726d7a4-1e06-446d-8c77-00a63f843c3b 74f254a4-b6a0-43cc-9489-91a176670603 b8ccd76e-847b-47f6-9080-c68a82e0c795 5c4741cf-8c66-450c-845e-23d3f2bf6f82 2b025f8f-ed9c-4fd7-af01-7c96434e491a b6214ab8-acad-4c3f-a5a8-fd260bf55041 208b0c3f-09e5-4fa2-a81f-d01d93830e34 de424f83-38aa-40f6-a2b3-2106352d2379 5ad0552b-712b-44eb-a752-bde8b23a315c 6863dac2-2e6d-4b9a-8937-b7de7fc11843 68a40175-e3ec-47d6-9a0d-28572b3bd75f c7e3fd78-193a-4172-ac0f-6be1f48c3121 2e936378-7021-43ba-b2a2-d13a7eeb087d 2a3ecf40-a455-4f4c-b1d8-72e5badcef2a f60a5548-97c9-4dac-a0ed-583d517fda1a 7b148a10-5e29-4bbd-bd1f-459980bd98ed 0fd4d067-116e-44e2-8448-cf1f78482edb 0092485c-c306-4479-b5ce-61563c17bc7f 482a6173-c12b-481b-b60a-95303b6c4d4a 08d1c2f8-282b-460f-9c53-349f672cbdb2 3eff8562-a7e5-4231-895a-13853267c884 71f23068-2481-4a5d-b125-e3a66a9f44ba 9f6f258e-4125-4ef1-b279-05a2589cf72b 258b315b-bd6b-4080-ad08-a5a79dfe7bd8 bbfa474f-1728-4ab6-9c2c-f3f22ca9e55a f3135e70-0c9c-4435-b88b-2603e3f8978b a668a89f-175b-4904-97c7-ae9c29e42a44 3133c1a4-5c9e-4f17-a96c-e43b964e09cd deddd041-58bf-4b0e-bbd0-f93ba508f80a d44aa1c4-d7ed-4f83-973a-3fe7bed4b6ed 82abb862-4918-4483-8836-49c3fe7c63fc 128ab652-c892-40ad-862e-84cb673f7f52 5be74fcc-e8ee-4c4b-bbb5-28903d3185ab 43a7e5db-bc64-4430-be4a-cd792e8848b2 790cab02-2344-4e50-95b1-8c49783d582e 5f0cf135-bf82-4ae7-827c-cb95b4d042b0 24ca7cde-ee10-4f08-a701-7d4af4b93909 b203a103-1afe-49b7-b6fa-3a0fd3f7b370 0207626a-e504-47fc-b1de-04b4be56b461 62458ce0-2d91-46ab-af17-2fea6c5a851d 7e10d25a-8426-40d4-a975-7cf0b4d7b296 a350ddbb-a0c5-4337-b800-d678ddd575d0 5ae34724-5750-4f57-becc-eba8ab037125 7757e37b-2632-4a6c-8816-78c3ca3341b4 8514d32a-347b-4881-85d8-2b18b11273de ff24f4fb-5653-4676-9d57-d22c5a857659 cb0f090c-e5a9-43a2-83dd-a87c244b257b c821a42a-a6c2-40ad-bac8-e795453c97ef 49f480e9-5565-48e4-a419-092b55726411 d35873f8-0db0-488e-bb30-df3f91d967a5 46384d12-9a29-4878-85c4-96adbdfa51f9 e38bc478-0aae-4800-ac94-17f02df43b27 f74a3eb4-94f8-462b-ac03-9494d41cc676 b144d618-72ac-49bf-8755-a7fcc29b13a6 98dabf37-d3c6-4d7e-be29-602b223396f8 4adaa8b4-091c-43f9-be70-fb0c495177ea 6dcada2b-e7e0-44c2-9339-4fefd692d0ab b9d240a4-dfae-4401-b647-ee2e943a90da 944ec89c-c37a-49bc-8072-e7f800b483f9 eab1c31d-c4fe-4685-8482-9199a8f813dc 21237aae-f09c-4644-80e8-27848de7b11b 58ca69f4-e06a-4f3f-90c4-258f6e74f477 da3690d2-ccf3-4771-a8cd-47cbe1bd82ad e935db96-cb8a-437e-b331-f43d4b652805 04f2c57e-451b-4c57-8fd7-f708834c13ec 8af19986-db80-460a-8d13-f7fc3e85804d fca26fc4-1eb7-472b-9acd-1ef7f273fcc8 f346a873-49e0-4992-8ee2-b61f915b45c1 390008dd-c172-4cf9-9060-2a4209dfb635 3a606ae1-72f0-4a5d-92e3-8d9085f57525 9f36ff8a-0354-4a68-8f81-82d27c649db4 303573d6-a0e7-4f5f-b7a8-cf5943f48eca fe552299-338c-42b8-8209-2eda7960b9c2 4d52d328-9953-4516-9482-0c94c6df07b7 5582c1c7-a6ae-466d-aa88-c20219247f23 184f13b1-eab7-47b0-ab57-082c35c12db8 5a688e8d-1fe1-4bd0-9f17-de92f104152b c2c2f33a-e455-49bd-95cd-bcbf401851cd deb8d79b-f327-4686-a89e-db0ef6a07a80 b45400cb-dd10-486f-8afb-2bf620ac7485 1c161d2a-437e-48fc-a157-140cb5451c90 0783e15a-7b14-4153-9aa4-23dec222a5ab 9dcd36ce-7b5f-46ad-8c07-f1a9e84f2a0b 217c8a12-12fe-4ad8-8124-828e3a5a7332 e730c195-7af6-4190-85cf-8cccc1b4af95 a335a5f1-304f-49d5-87a2-1652dba70d3d be27f3dd-bb9c-4fe6-bf46-d2c226548d6c c1a5ba16-89dc-4829-967d-04740bb7519e d8b873a1-289c-4baa-9f70-56463936c316 4c605525-c9d0-47af-9445-b09be8cb1a1a cf3b587b-e225-4f36-a466-8ba4645b9116 ab091b26-f084-4b94-a348-53b7b3014e63 3798f860-f820-4f3d-9620-6e8a088f54d8 7cce26c7-9365-4853-8610-420db620c359 7ec07d75-904d-4a45-b4ca-5f351a435d6b 33456ea0-9df0-413e-bf9a-23f76c6f11f0 9da6dc68-6bdd-4f40-add0-f49d99258a69 228f3ce1-9b45-4d49-9058-9541e659ecee 830d9968-2e6c-4cd2-8823-5c857f418f49 37b13d0b-6586-4e0c-844d-dfa9eb6647b2 a18bf7c3-4d3a-4079-b21e-c25ca1bdf321 2f7ce5d3-669b-4c60-9fe6-af35ad0d3fb8 2109ed3a-4acc-495e-9060-33a7162ee03d 3b2c3c7a-c24e-4aba-aea1-4a4f003c71be a7c6b328-3b36-400b-a18a-0aecf125b16d bf22cc86-3f92-45e9-907f-988bfc4689bc b37aff10-20e1-405b-8350-b2024e2fa14f 57f949dc-dbda-40a7-8699-63d979af24cf ba033e2b-754d-4cfc-9d6f-c5f109625ab3 128a1668-33a7-4ac3-81d7-f13e27019bbb 15242dc2-4fe9-4dd9-bc8b-9c11e3995b68 9a591b23-6f43-47b2-bdaf-40afeef276aa 6323b28f-16a4-48ab-8e82-459e7d148736 56fe8ce6-46ac-4ea4-8264-75edac6ce85f 24590ea2-1200-4c1a-8ae5-25ddaf09e045 2c493c94-f3bc-41a6-9f48-50265f1e4c83 155b787d-5a59-4d9d-825b-cdba69b5fab3 2387e05e-66fc-4461-b88d-0b372702919f 4942423b-bf9a-4494-9a0e-173c9ee66fa9 3ac657b4-7c01-4244-a061-f1060e2eb718 ffd4b059-2f67-4c69-ad8a-711bad772c61 c9c0a240-d5fa-4306-92d8-c369ff41e999 e7ab2d45-aba4-4cda-95e9-1a1bb6f96ebe 9091a89a-c7d4-4205-9ba8-761f651a4c6f a62cb659-86a7-4de0-bc4d-a3ef656fcd3d 9ea69744-3eb9-4a68-8999-1ad08ca80683 d288c4b0-1ffc-4f2c-b484-127edb453119 02823088-1585-4112-be9c-c30d8df2479b fc8d66e4-1f18-48f2-b990-ac39073742a5 1146f6d4-fcee-4bda-8685-c1a3eabe1fcb bb55dfac-d831-42ab-9f52-98ab3e06fab5 d4e68451-68ac-4189-b97d-c75c9e130641 422d95d4-3d49-42fe-9c01-b49015dfaf4e eebf7a3e-cb92-4cbb-a9e7-882b7002b4fa f1837c61-9b7e-4c2a-b663-f39affec43a4 6c76b1d7-ff9b-4f54-983a-9a7e9c1fea06 e2e21fe6-a384-42b9-84d4-bbf855346618 b0abbec2-ae2e-42c7-9e33-4b76c1785074 9968b21b-6b6f-4939-85e7-2c434976dd14 373388b0-1d7d-4f4f-9060-d7e2750a5839 12adcfe8-cb69-4298-bedb-b8266eb3912e 9ddc02d8-33f6-4d9d-8acf-88d954c013cb 308a0edd-68ca-4442-967f-25c85dd8fbc5 594c93e8-c1a1-4f0c-96c3-301710686f0f aefe1e19-674f-4793-9b53-55f072454bca 5c7958de-cdd5-48e7-8346-e500fa3ad086 ee52edb0-bdbb-4e31-a235-dd02429ba52f 09584572-ef8c-40f8-90c5-f27dbbd5151a a9f7f020-41c0-4f6e-8525-83e1821549ca c7b85826-f6eb-41d7-9b7f-abc3b1127aab 94be88e0-17ec-4f07-881d-e106876721c8 6ab9af9f-fe84-4a01-b42e-df06f925c70a 8e714991-cacd-473c-ad70-3c7ad4eb3cfe 603feb53-618c-4969-9873-e37add02ba26 3ccc4d73-3d38-4da1-afa2-15f9fd622ad6

## 3. Inputs and Contracts
Input: Profile metadata for import_bookmarks_merge().
Output: Script execution status.

## 4. Execute
- Write import_bookmarks_merge() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "import_bookmarks_merge()"` or `bash -c "import_bookmarks_merge()"` depending on the environment. Expected output: success for BookmarksMerge(SH).

## 7. Done When
- [ ] Criterion 1: import_bookmarks_merge() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
