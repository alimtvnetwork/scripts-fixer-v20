---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section20"
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
  tests: "unit test-20"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 020 — Bookmarks Replace (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for BookmarksReplace(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Handle --replace. Write {version:1, roots:...} omitting checksum. 33666cc4-655d-4c4b-b023-3e3cb1768277 90c5cdad-a83c-4655-9bb7-0a4d5b17342a 2223ff9a-1ef2-4637-888e-2140266c7973 cb8b5c2f-f1bc-4e83-b9d4-cd045eb771e1 d9c32159-d504-4c18-81a7-4cb490547528 c003f5e9-a2c9-4e79-8837-df9d5f9b0cec dfbc2058-e1b0-4e09-bcc0-43fc82207ec6 4c81a159-b420-4c98-b484-ac84de8706b5 3d655f3f-dae3-414d-b071-97d26a90a0d1 1c656a30-bebc-404a-aed8-79c76f6403ea 46e8b5c7-e150-4879-915f-ffd2d4df8f83 a5af266d-617d-4041-a50a-b415a2979c51 3b36ba8b-8932-4db1-902b-ec4c8bfa4504 1be655ba-5f2b-4d57-b7fe-f2ab298a59a0 b2e45f45-fe7d-46ee-a291-6e8282d8949e 30b227d4-50c6-40ef-99d1-0b7995e4ecf5 6b77ba8c-f147-475f-a064-42d0bc36cbe1 1276bceb-a295-43bd-8f0a-272fce6bb8ea fc34e332-5b2f-4fed-8fd4-fe254f087cee 7545fa6d-bba8-4906-8773-5f6dfe694c81 b3369e72-cab8-4393-b63e-ab76e02ba677 de75684b-624d-49e0-bfb6-1e40868a07d3 0aaec9d4-a93f-4401-bb02-c41e3e10c2a9 5f8a6d0a-a969-43a8-ad10-34fac720d7b6 410fcc2d-b678-4ea5-848a-2f8278ec59fa 2dc5a39d-519e-4ca1-b968-bca8e6e14a5a 6c57a08e-22c8-4e53-a3f8-b8692e98779b 52c29fc1-1cff-43f4-a122-d43ab381685d 9cc92b12-52f5-4841-9528-5833ba507aa5 b466717d-8aec-4510-835e-56f408912ff6 465270f7-a8c4-488d-b79d-296413e76da1 aeba3738-1228-49a0-bd1c-1cefad00048f f2b8769b-bc54-425e-9aa0-8b2cad07c2b4 227e36d9-2ceb-4dce-8080-c155db1e615a f6a87173-0321-41aa-ac6d-388b30a27259 4995b7a2-f295-4583-9749-a04df0580abd 8e17b4d9-f684-4d89-a6ce-af3599c890f3 a3e7a434-980e-4bb1-b975-6cb8e9a73507 c703a21c-79b2-4ca2-bf10-99c476678bce 86fd56f0-7367-4d8b-a205-8b617142e006 49ecbbe7-5a72-491e-8622-01a5cedc2ab2 8f1b3c8c-8fdb-4344-8e82-b33a557d9087 8c357269-45a6-47ae-91df-0038a7e60a69 e117c183-072d-428d-831a-b7f4ac4b4eab 20915cfb-557e-4312-b457-c436d65b135a b07e7353-5f2b-4c0a-8be5-35071596ff35 b08bab95-fb11-4678-b984-a12b98f29178 5fd36b43-03b4-4757-a9d3-a9b7038fce29 6161ba1d-f039-4a92-b595-788fc1cf3bdc 9f8bfc54-20dc-4c05-9e06-cf4ede98c11d 1997f580-4c9d-4cc9-af4e-52d92db67a58 3d1b4150-bb76-48cd-835d-3f932d98a163 da7cb9f6-f83c-4ee0-b32f-86d4d4c78f7b 0273327f-0c31-4546-9ead-90d4a8147d58 35e01ce1-2fe3-4f3f-9605-42f0cc379be4 7b034149-23ac-47dc-853f-05d8f6e4343a 555946a6-023b-40c3-a4d0-d413c2200abc f345d06a-b5d8-4938-9207-ba0015198f83 981ecf45-07be-465b-a071-9adfb5bceb60 150e78a7-20cf-48b9-99a4-526d3242e86f 0ca83c4a-870d-44c4-be39-297fa53491a0 75677375-9e99-4dd6-8842-5d6058545148 5d3b29f5-fd50-42a4-a879-6339f2e0c5ad 941dba4c-6062-4501-ab5a-19ba09973e88 883dd2fc-b781-40a5-bbab-210fc7e95e64 5e5ee538-c87b-4735-aa45-535424bb23a8 db4cee00-9ca0-4263-b87b-d24d76af8560 187cfb09-dec1-4af0-8c00-e80252d3fa1c 3ee7b39e-71d5-43d4-a5ad-cba865775acd 4c07dd71-4a1a-4081-aebb-f3a6cd079d2d bb294ca3-4f31-41bd-972c-e3fbe833aac6 c90280d6-adfa-441c-b4c1-1dba2ded88a5 515ff41b-d814-4c73-b34d-525bd2966b9e 9d4c1588-b3f3-4918-926d-43ebed7f5c5d 8d4d2041-258b-4c8d-a743-71e6d89c34e1 24009651-1d98-45a0-b0d3-5ef50b708944 ea62bc39-5f54-4d41-a7d5-475feed5a338 342626d1-653d-41bb-ab98-0546fa3f4ff1 91196b41-2156-431d-9f0a-49827c51848b 815cbb68-82bf-4096-8a1c-b896dcb7b253 b9a3f473-fd2c-4eb9-9e58-a7d7f27ea98f 5bd1ad67-3fac-473e-8dad-4ea8e25e4619 01636054-44cb-403d-839e-f573d8ba150d 5cb49883-adb6-4020-8874-71b21b8996c9 581ba671-6032-4e0c-a85b-acbc54d5c10a a8a2d956-9509-48ea-ab05-4c960da88e99 e5300460-f686-4a69-ab25-2997b7d4e95f c68ed6f4-3a8a-460b-8ef2-e0962794617d b3240656-f756-4670-9b31-30651a6288f9 0b21b8f1-0258-4e92-a6af-b21d6c9714ed 33802d07-001e-4f52-95e0-fd6d6dc6d4c8 9fac7aba-8953-424f-b171-82ecf80e76fe 5d988648-db38-4fdb-bda6-7033a0b82478 26bfa2b6-aac3-4a6d-951c-d76d21eba190 31962cdb-a3ba-401a-8363-3f29b77db19a dbbf9ed4-a128-48a2-b746-209d11039714 3e05b0ec-1e6b-4c43-826a-9adc935ea06f 1fa9cca7-4ff9-415c-a1a3-10fc0afbcf47 e105ece3-7ae6-4302-9225-ae118b8fac9a baa53bd4-ae95-42b5-8bcc-6c426f70d3b3 43381020-0670-44b2-ae3f-995292dd23f6 0827f88d-0962-48a4-841f-049ac5c03c77 419c0217-59b0-4f81-8dfa-9876d3bd35b0 0dac3216-513f-4405-97db-adf02a9430bf a3e73d99-45f5-4648-a965-9a0030589ca5 f458e700-6849-4636-b97c-29ec09cdc486 ee6d9030-ec6f-4459-a8d2-7e688d9f9c61 36a4bff2-0056-4e64-99f6-09c270a2569e f87aa480-ae01-44ce-b65a-68b87f79f526 73dba1c7-a0d6-4e32-bb4e-a85db727f274 0eb2451a-9f29-4092-8c5e-d94c699a2813 fbaa1cd7-0444-4902-b39d-32fb29fda126 8d09c300-71a7-47cb-aeaa-ec5002b27402 16444588-ec3a-4ee9-bdaf-ab259cb51c01 71e9ca56-b735-4fa7-927a-262e5b2aabb5 20c30c45-6e60-4425-a8cb-6f9007eea793 6e53d6d0-0d4b-4cde-80d6-7bd7e66aec60 bdcf6803-d1b6-4fa4-8a54-8c9549162982 581e7a14-c2f7-4c95-8378-a41f275efd92 6b5a1901-02b4-4131-9dce-4bfc2bd10b61 9dd96f05-89d2-45f5-85fe-839141e3993a 507bede1-13e7-49ce-ba08-71e75b9d18ab 5ff3be14-ccc1-4f40-bb42-5a162a411107 11051456-b658-40a0-b3b3-4996e974a529 fc82fe67-c538-496d-8912-6a8a507d45ea dd39821b-61ff-4f6e-938a-8c090675a90b 5a337465-8d5a-402a-ad19-8bccc257e855 76c0d0de-49e8-4775-9130-7731dc9b45f6 0a58ce37-f696-4cfc-8b46-d9d4893c0882 fa3dde42-e58c-42ba-bc6a-06d2caf576fc f27e98d2-a055-43a6-9e56-3b9cfd025dc9 2da7f7e6-c5bd-48bb-a0e2-6797e0c0c110 5e95f7e4-99ea-4ee9-9bd8-c1bc8b48fdca 31feff5b-5d4e-4eb0-967d-b17c6fd18fc4 f022ed64-2a4d-4569-b936-f11950b1e0c9 0feee764-c264-4583-9bdd-9b3bc31211c8 13c9c77b-0c82-440c-aac3-4bac9f194386 7ed32ce5-97c7-4b18-a075-3feec280657a 66ccfd5d-c03c-494e-a32c-aa2f7587e896 bcbcec34-d38a-4228-a083-a41c1ff02180 aec947a5-22b7-4924-ab33-7700dd25af4d 263858da-a8be-44ce-9ac9-573eb4fe0335 42e0a411-66ae-4334-98a3-5ea12bbc9c93 ef128813-8bec-4dd8-adcd-dfc8b06ebc4e 29f0f178-b6a7-4686-a76a-171991c579e3 dad29b59-d01c-4118-a62c-014b322ff9eb 502bc27c-2532-4143-a42e-3c883f7a6bbc 9444eae0-5d70-4674-8560-5e5fcfaa8cdb d0d72f8f-74ce-4e89-87bb-6fe660b2c6df 1b74280f-91c2-44b5-bb9b-cae8a51acfd8 dee9feb3-0d7b-4054-b98d-e5256a6c52ea a5240b3e-18cf-4c87-aa6f-1bc1facabcf2 6bcc258c-e636-4e3a-bc04-f8ce0c648392 92477956-7ba4-4d50-bc31-56bc627b4a01 9aa498e0-ad62-424d-b0a9-a53f5ab82919 76c3ffe4-73dd-406b-9548-1ddaaadd1abe fda007eb-dd32-46e4-983d-b16e9e13a417 09c96a50-2bc3-4320-a92d-884c957e9f67 70343cab-62b0-41ad-9766-463c24c9656b aac08923-4271-4742-a7ae-3e84801a3093 fc90dc14-9b15-403a-9062-91835a54ec88 714cc5be-7182-48c6-9261-8e947993c0b6 ec1a5651-9d35-4ed3-9747-d91f0b62adaa 57be8e61-3d8b-4767-9362-4a0e2ba95ad2 eaecd5f6-b891-45c1-a13c-842630f01090 0989591d-865c-46f1-a6d7-76e2b0640e99 0bb74ee2-8ff3-4adb-9eab-ea44c6c021cb f1e10e14-6be8-4583-97a2-b66ce4051c65 eab17706-9565-4c91-9d9a-12e319f30c67 f7994667-264d-48c6-815d-8fab05bfbf26 0e10e886-4e85-43a8-94bb-bb88b1ce4413 85d20828-5356-4f44-a861-4080570181a4 4eaf8e15-731e-4ae9-addb-8d4ed754ba80 65e22853-ff45-4a0e-ad72-3e5526390163 e1dbc97a-a3cf-491b-bc2f-121223d8100f cd82a14a-9c7b-40fa-8ccf-d3f96a235b7f 8dd972a9-0a93-4fb2-8e04-75776868fd1d 8718ef1d-4e85-4b70-9a08-8812beaf86a0 c87868f9-44c9-4f0a-bad5-75ee3395b43a f8be2bab-e905-4d4a-8466-3510825f4de2 c549c305-2389-47ec-8e35-07adefcf1bf8 ffed29c9-79d8-42bf-9c97-bc7862ec3d82 278c976e-9e8b-48a7-be79-7136cab5ef05 c0a14727-23e3-4fd4-a8ef-6b060379696e a54f8aba-c4ec-4a65-9e20-bbeba98e08b4 885e41b4-0fdc-4b5d-acf1-09652b76fd01 bcff7654-1129-45e7-8e7a-dbaf52c16a2a 70b6ede5-b6a2-4144-90bd-fe00b68a82f2 e8a4a49e-4041-489a-8e10-b935e2e23b64 56bd423f-4982-4cf6-9dec-cd7db0b46ec9 8fbfacc3-8942-4fb9-9a0d-947a974cb301 ba403683-29f6-4aff-95b2-2ab72dd204be 4dcd4925-b055-4d8a-801e-c04f83905727 588a6c50-f916-48a4-b35b-29301243866c ae688cab-c59a-4667-b7d1-6441ea9e2ba4 af03eb46-2e1b-4109-b072-fd82066d8c02 b0fcac2b-05d8-4dd2-8e47-68cba2a4b4ed 4e9f034b-d9ba-496a-b73e-d84ceda1128b e4dbdf25-1cfe-47dd-af2e-203db8ccab4c c06d09fd-c6bb-4a95-a309-983705cc8a04 b72dfd22-9709-4547-94d1-e010c81edb3d db1d1475-850e-4316-8f29-d2016ab00d47 46cb80ad-7058-4b72-9338-2e33bc04e925 73189246-dc5a-440c-befa-64beecd3414f e4b196a1-6624-4a1d-b74f-56824ecc88d6 35658b42-bee8-44dd-9298-84b32cd50b80 599915b2-00cc-4cf2-bdea-18196c026f4c f9d50dfc-fd72-4602-9970-454db7f08aaf 0b00b83f-ff9e-43c9-9792-8ffd07a6daa8 95bfea66-32d2-41cf-95b0-a2c263f03e8b 718fddec-2a3c-4329-ab11-04bbaba7da6a 8a106281-d524-4521-b2fe-439d5b333f07 a82fb9dd-9dac-41bd-a43e-5d1d27036c9f 7dbc9ea6-74de-42b8-9b37-ba81d82260e8 a6cd1b92-a122-4e86-ab51-17aa5d5fe499 5a35e77f-319f-4a9c-94a7-182e638b73d4 34026ece-19b6-43d2-8f4b-40a5f5586f73 f1708424-90e3-4436-bf83-5bc14db4ea4a 733e8d95-aa71-46b2-9e78-679253103b08 daef6241-eeb5-48b5-8048-9aa093da29b4 b0eb8094-aa9d-4edd-9238-677a15714d5c 4a116b10-3369-4c11-b212-cbe885b09a81 1ef5adca-8462-4e76-b16f-2257648c11e1 adad1faf-e7d6-49f1-b789-bb4f988c89d0 1a465dfd-a2c8-4b85-8dac-356546d4c7df 00be4d0f-b5dd-4fda-a9c8-3de8937b447f 596cec24-d877-4480-ab99-9e0010189a3b 4346d8ef-09e8-40e0-b408-d0b6bcf5a49e 63fb0753-3cc9-4764-8816-204b40f6a22e f3f9b853-2a97-4b0c-8d59-7eb1eee894ed 444ddf69-f23f-4a58-bc0b-8935ca7bcd25 72c41a22-53f9-42f6-ba84-fe2934a97628 927bb1ad-515f-446f-92a9-c0ab287866b9 af56b4ec-fd46-4af4-b9c8-f976267e70dc 31604551-50bc-4a92-a050-b7f2d4880d21 be1450fe-4a12-475f-972c-ed1fbedef6a0 f6429a96-bf15-4e67-be12-1cefa7540083 1ac8cdc5-e0e4-4b88-82a4-b29c6f002f60 5dffe96f-4495-4c17-bbb5-716eca863d8b 80feb9d7-c9f3-4a68-a3a3-c173d449d17e adbbc1d7-606e-45e5-8752-5b6cfea7727a 712e2cef-3ab3-447a-84bc-5d4296c9c177 2ba10b08-970e-4a4b-945b-16dc3137cd8c ddef7bc0-c538-463a-ac9c-b1b52ae9e786 de1807e7-51e1-4643-a83a-db1cbb0a2bf0 91b6b567-3645-4e27-ae85-688cd9e896fc ecfd508d-2869-4dbb-89cc-1dfe4e0c8307 6380d1bf-711b-45ee-9dee-6008a3d0ba31 60310c0c-6271-4b43-9006-10b840620534 593a67c4-802b-4756-a798-be470a627454

## 3. Inputs and Contracts
Input: Profile metadata for import_bookmarks_replace().
Output: Script execution status.

## 4. Execute
- Write import_bookmarks_replace() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "import_bookmarks_replace()"` or `bash -c "import_bookmarks_replace()"` depending on the environment. Expected output: success for BookmarksReplace(SH).

## 7. Done When
- [ ] Criterion 1: import_bookmarks_replace() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
