---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section27"
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
  tests: "unit test-27"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 027 — Search Engines Import (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SearchEnginesImport(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Read PRAGMA table_info(keywords). Build dynamic INSERT. Assign sync_guid. 2599a159-127b-4647-a2bd-7f47fe59cc81 9c7a3b64-ee6e-4a65-ba76-6f74d5dc6cad d0293800-e729-425e-ab3b-4e2989df3a8c 51e02722-2936-4ff4-91b4-996bb92cd2d2 08a4aa18-5439-4b1b-a456-d6847d485cfc dae1a9cf-afd7-4a6d-a63e-3a5a56d5e107 4252b02a-a139-41ec-901a-0a0adaecc685 8b21486d-735e-4534-a889-6f10c8c35c9c 1a6529cc-3c9f-450f-8115-590ed52edb5a cc59b0ba-5e7a-4f75-b2a1-37266cf96400 e0f85278-d7ea-405c-8b50-5a9b77e46ef2 88b95a88-7549-4b8c-a2f5-a239dffdc48a 6344b8f9-ebca-4e47-a86c-ccc42fb8ee02 07448719-0f86-442d-ad1f-600e132299c5 b671f08f-d9e0-408f-b049-31d6fc924a84 24b7fa6e-6ceb-4aaa-af66-9a790a528081 9aef8cce-deb7-4e42-87c0-17440599f6a6 f5692810-61bf-4165-bb9b-437f22ff363e 65b7f805-38c1-40e2-a6b6-d86a281dc4b3 454d1216-caf8-41c4-9aff-c00482dfe27f ab9f4d9e-1aeb-469d-8903-78acb37d62bd 5b52e971-fa5b-43a8-ba6a-867505e1d9ac 4cc150ca-3551-428c-8f00-b15426705513 6a0534a8-1a32-4019-a12b-a3f818e5d357 ae693014-ba8e-4400-b8d5-82972447a4e2 747d2bfe-25e4-4d89-b325-afda5687d4be be961b14-4585-47da-af7e-51de4da0e836 927a07d7-73b0-41c5-8d29-3a8ea9d4a3d2 6af4e051-f77e-49b7-b518-1deac42971f3 e90651aa-1753-4a39-a217-9fda44525dd5 0aa653e1-72ee-46a0-8018-db6253696fd0 723a1ef9-06f1-47ab-9866-8d68c7af0107 43fa7d14-6f3c-4341-9342-5242bff26dc6 43ae144c-0539-4d18-9493-9e592bb09e9e f7c11697-f505-4fc0-899f-eb621293942d 02a26c3e-51f2-4826-bfeb-6380441229bb de066d18-14f1-48dd-8be6-e407304f2770 9ee814c9-dd05-4fc1-a0fd-064c0a492832 cffb27e5-12a5-4f07-ae06-0505c28931ab 1c52ca37-2c8a-4dc4-8b76-4e419aca5c39 1de226da-69bd-428b-93d2-9202170c459a 7055d0a8-13a7-41b4-b255-b16978c022a8 1252359c-4f96-4b74-929d-855f61d692f3 9162baa2-d7c8-41d7-8c2e-8fef13c28fc7 f472fca5-e869-4670-82b7-62a404f550a8 ebd94d91-b4be-4b49-a7ef-eea1c39f169e a6cb8e99-0ee1-43c9-b2be-bec826b202f6 9194222a-e260-473a-be2e-503c2499d189 f290dcbe-bdf6-4a2e-9c18-492983b5f405 2cff045f-5707-4a50-807c-b35d47c01035 f3fafc8a-3a49-4b82-93d7-77ad654980d5 ba4210ed-2842-4ca0-ab00-2a100c58fab7 fb0f76ad-d29a-4ce0-8e48-189c416fa482 34843231-00cb-4693-b64d-2ad40874d30c 0c4b3812-61cb-4201-be7d-09d26b046525 6e5b0217-fb46-4028-b5e8-6553e99a31a7 5ec0a41b-b914-4488-9bee-21bc7f394789 76782464-5807-4769-9c04-6cf395b7deb3 55b30fd0-f41b-4080-9c4e-ab0011f70bfe 8c3bebf8-5c63-4bed-b568-a878c9ad4b77 9226461d-b8ee-4c7b-a520-e918f3c60abc 021320e4-e1c9-4b11-8f36-f01347a3c0a7 c6127c19-4584-4995-8396-c3e8d663800c 218e2a8c-1f39-4bc0-ba33-592729d679db 084e6afc-4840-41b8-85cb-c3548d58f829 1e67e24c-a6ec-4281-82cd-ad3271c62118 bacdb757-d975-4291-a90d-52b324c88200 89536198-697a-4cad-a71e-7b623fcf55c3 c300119e-f9a6-47dc-8e78-514262a1e23f b25c6aa3-59fb-49a8-86e7-85e6ec1de2c7 d3aa5ab1-460c-4ba1-960c-7c245afb1138 bdd198f4-0c5b-4ac4-9960-47a072c7b989 d12879ac-6247-4988-8770-15f4c731d441 261965e3-ccef-4d7a-8459-0c8ef93b1df7 45912b63-a479-4a57-91bd-89bb00925a30 b98ad174-f042-49f5-adc5-f05a383bc48c e523f6eb-4a5a-4eee-adda-b9a1b2dfcac6 e84fb636-9853-4d0b-a8b1-49d15bcec4bb 9a2ca990-ac30-476e-941a-f03b5b071ca8 52132f1e-87f9-4cb3-92a9-68377a7a2b8c f5ca507d-d4a1-4924-a36c-fe2192db0d7d 36f91706-8a52-4ad7-b25f-dbe644ed1bb1 f8d39d9e-8a87-4075-a6db-6dce8e679d4a 614e3333-bf5c-402b-9ec1-221baf210ed3 1acc6df9-01a8-449c-be3b-41cae905e609 308d445d-3508-4907-95c9-483454907465 761c775a-e832-4156-9996-3922c6371c40 22f455b7-3b0d-4657-9d48-9f223edf0770 9261ab0e-fff2-4e4d-ae8c-f52a6f691895 d1165ef3-4cb3-4592-ae10-7a6e80172cd3 3f04b83f-195d-416f-ab3c-ff0ce1911fee 292ef304-f8af-4663-b729-b0622c2f93cf 58b3021c-7615-4a11-ae4c-f573ce43b72e 6b80d32a-3803-409d-be36-543935ba460f ba17c7a2-05b1-4421-9048-22bf30b1c853 2afbe37f-b96a-4220-99df-06b888755009 ccc2dbca-ca39-4dd8-b10e-0e59705a106c 7af1750c-c4db-4341-a52f-3c81ce676cc5 61d327f8-f667-48af-ad24-4967f2253a55 ec75d8f9-a64a-4d32-9bc6-68cffa8d9009 c6724049-40a5-42a3-975d-10c2f6924684 32964073-644b-4cd7-81f2-cf5c40326ca7 7ab484b8-0bbd-4005-913a-62e0d1fd9b25 52529c34-cdde-45c9-9443-3280733fba12 a0a8a4cb-c4c4-440d-8ddf-f386e41273e5 e8ac8f4d-05b5-461a-b1a2-571faa311aa6 210ca238-0c89-421f-98a7-7ba75504481f 972d8c6a-1328-46e7-8ca2-192d5c4e9d43 057f8c8f-8ccc-4316-98f8-187a8eebf014 5d87cb49-9c60-47a0-9e59-b8804424d24a e6b67533-befd-4cbe-96e0-e218e212e0fb a739b250-8962-4197-869e-7b4c25202e24 0cd9712d-493e-41ab-8227-c655d78020d8 e77ee13c-af01-42fa-82cb-c7e6a249b2eb b2a86d2f-b53c-44c1-b1bf-e6d15be92a3b 73af8b0d-ac0e-4a6e-aa0a-4174619afe5b e9c15b8f-fd9a-4952-9d0b-18d33f79d1ac c18fc3ce-76eb-461b-a268-4e8b1f25d47b c1e488c0-3f52-4993-bf51-d360d11da8bf ae8aa2bf-dd59-4369-8dff-9735a319cb4c 4668f6e8-cddd-4046-9921-54d041e883ad 2a82159a-1e29-45bf-9f5b-a04addd5be33 b991352d-0bda-42bc-b2cb-3f48b6b49161 9ae69890-0f64-4c42-b330-f416e5da7a5d c82b04e8-d450-4ff9-93e2-1ef12398a0f1 4ffb611d-76bf-4839-80c6-2ea24b7ec13b a8a3b932-f823-4735-97b5-f1e65a10138e ea5bf2f4-3348-496e-a783-8c334a633a0b df70c83e-6c17-4664-a6b1-fd948e1fb13b c2adc2ea-912d-4fc0-b24f-137ebcf860ae 6963fe4c-06e2-4b8a-8712-f3c776fea872 f02ca283-8622-41f4-a8f2-900f6d61886e 4bd96d65-b9bb-4a6f-86d7-53efa0c974e3 ea220be5-e01a-482f-9636-aeb725085ee7 3a1c8b4d-062f-48d9-9dfc-683b0cda62a0 94c9c022-9b07-4b31-98c3-769641cfdeb1 e006d168-1db2-47c5-8f26-b37b03ce5761 7426ff32-d77e-46bb-8a84-394ae720eb16 009a5c59-ad36-4dd7-a0fe-647d2dd59f07 f73f9288-5b23-4db6-9bbe-68add65a060c 14c4bf56-3bb6-4aad-9d83-cf5360e0e52d 5fd8e6b9-f563-4dd1-82be-47d8b508e7db 79877fc9-e6cd-437d-983b-5de44be64de3 1a9db342-0c41-4094-ba6c-5ed43e7438f2 a7acb6ff-7a48-4f84-9947-2155701e0580 0c956a0e-004a-490c-a91a-8053fb29888e 1eee9c9a-a6f5-4920-bd1c-7fb2363c70e6 a7cd273d-88f7-4d2a-80aa-6ccc48f2c543 38184000-8a6c-4207-8ac1-f8e58906a6f2 cd5483e9-2e71-4834-91dd-ee46a2de0a21 abc7bac4-c42f-4a7c-a4a3-8b67da132ef4 d7ebdb58-2564-4cfd-bac8-0bcbf09be308 09b13f76-9aba-4afb-95bd-280a35b115a4 6ea370dc-70b9-4ed5-86eb-da2de57811d8 919a1b52-d496-4add-8e8f-7de236d5048a 08762203-35da-4ff6-a703-f52587b8d9fc 8252dc45-23c0-4cb8-bea2-72f3cb8fda25 f5650dc2-75c0-47af-a463-dc7ca3c36fc4 b612d94b-9dfd-4be7-aff2-8a2bc13e2694 0031a68f-7be2-4ca6-9200-10be42256115 7e01117e-bd1f-429d-a3a7-48e2cb3f2233 155fb555-4568-4148-b740-8234f51ecfc7 b92e8322-aedd-4ecd-b6e9-13e01ae2d842 48f9250c-46d5-4ce9-b789-30f3d5a95da1 fad70b05-172d-46cc-b803-2b882e7161e2 bc60eca5-1dde-419f-a655-5eaaf5033f36 d20a7b65-f393-475c-92f5-74bf832e11df 5edf5bae-b748-4b0d-a9c1-4c6f3dbc9456 3c0938b5-ac17-4542-8a33-b2a4e6766026 055fd869-7a8f-47a1-a32a-f11dc03cd888 11e47bd6-d412-4607-96fb-3769649ac114 b1c11a2a-e9e8-43e0-ab21-16210bb7d521 ff33177c-e4ff-4f6c-bfd4-8267226fcf57 fbab07ef-e30d-4043-9858-1183ad4e3216 bdc92f2c-5045-4127-86ea-d44d50d27a34 bf3c48bd-e5fa-434a-b1d1-739b97634197 c8d48e19-cdda-40fb-a5f1-07cd759eedbe bec1933d-79df-4a17-9fbc-a1977af90e07 9e280f2d-0603-4999-9113-da847259c130 1ad0471e-bc99-455b-9277-18b0e516f0a4 48401d15-0833-41ec-a826-b78fe6b6e903 2bf97085-3629-4c7c-9632-22adb20fb08c aa59ba7f-dab2-40d1-bd0a-fb243f0619ae 82da5bc4-07fe-45da-9cfd-4851a6126215 f698b56d-a424-4c89-8a10-01e7c6fc0e06 fe38d806-8d5b-455c-9f8d-f8dd3dc4d5f0 cded020e-c6b7-4297-bc54-118f5873b3d6 43e9ca44-e379-4ecf-a230-1a5e5370805e 83e392b8-a121-4d94-8987-cad8f6e3b76b 5f254292-83c0-402d-94c2-35d2652af17d 7ddb17b5-8c7c-4854-bd67-977b1e55c939 419e3c55-bdfa-4f8f-9284-f18613c48618 6ec8bb28-d78e-4428-84f2-adbed1fde363 d407f4a7-1250-4fcb-acae-c38a8a1ed24a 6c4edd02-bb6f-4c33-885f-adbd7e087617 6be5a5c4-7358-4839-88e4-b9cc80dc532d 84fa13a5-034c-42b3-96c3-74d5f2a5935b bb0b2328-3f0b-407d-aa01-b60f59765840 ea93a0b4-a321-4e2b-af0a-c9ae982c3e38 00964eea-0545-424e-b98f-f27c560553f4 adb6af61-4a69-4258-936a-055b47e66c19 f6910320-3c46-4f15-ae4f-c97654f9231b cb367ecf-dd28-453f-b6ed-ac8f6699edf5 f45521ef-eeeb-4f17-a201-7db2c3c6373a 7e861eff-743c-4da4-bcd0-a3f79fbf19b9 d8615d73-72b3-4ec8-b3f7-c5ace4846f6d 3760c2be-9242-4898-a273-ffcfd94beaaf c6a64d2b-390a-420a-b13a-23ec287c45bf 7c1db697-ab8b-449b-a2e1-5e9945728e5a f877b70a-bc07-433e-8239-75de2f934fa3 cdfff558-aa71-436d-a2c3-53b041f76b42 695b5839-263a-457a-b145-062ae485a73e a4ffd858-f6cf-41b5-b727-48e52e58cd9d f4fee493-5a4b-4558-af73-5d0937ac456d b7dcfb7e-5e01-429f-9422-c46aa3da3390 25254c4f-9e79-4ca4-8847-0557cd92ba93 e8c31806-01c8-4b48-8779-b638ca3e3ed6 b6b16471-65aa-457e-879c-f0a7c6d0c96d bfc0dac5-07ce-4630-9fa0-6ccfaf4aed35 2df87bb1-9cf1-46f3-a025-9c0b311b74c5 af25b9cc-05f6-410d-bb4e-970ebc78eb20 ca42afea-de4d-4d80-b93b-aab5f3d6354b 600d9a3f-396a-4fd1-a276-66d54613d44c 83f30af7-9170-42ae-96ea-2d64187e0e9d 611a5bc4-a280-4a87-8a36-1362fe6ced66 03669580-bbe2-46ba-8cd0-7eddd178c725 de2a53f4-1161-4128-ac06-a057578020b7 cd60ed16-96d1-4322-b29a-283d8863533a 7882f9b3-1761-4264-b3c5-4ef801a24e45 8f575ea9-150b-4bf9-aea0-7fddc84e8a35 82a7f2f9-6922-4a61-987d-ca04d07e168d 2ac0aa0a-0480-4f8c-b87a-ad4925b33acc cd69ea0a-f6a8-498f-a917-0bb726585047 9e8701d0-0085-483b-a1e0-1136833ba0dd a4418a89-c680-4ce6-a44e-d45852891a19 4c955283-61ce-4e5d-a691-a4e888eece76 b8496241-25f2-4364-b657-e79c2cb550cc 8f9ab4e2-472d-490b-99e8-5df28468c22d 31c646d3-3012-4076-9452-e0ab0e4422a8 384a31c6-493c-461c-b1f7-b742bce24668 c9e965a5-1815-4796-b6f6-23de366ab042 5368e8ab-2cc9-4618-b205-7ecc6b5776f0 1883ac10-0c31-411d-8b53-2278e291983c 1e6bcf42-0a2f-4e73-974b-0dfd38b14846 2cc752ff-92aa-4056-b707-e46807bcf1ef 6a281e41-8e95-45b9-a905-d63c71434fe9 32d00dd0-584c-42d4-9558-6a27424d7c7f 2390cc33-e911-495e-b667-8b9c2133d410 7490adc1-71fd-45b2-9941-a65cabd933bf 7e779286-5241-48b8-a228-f0b6d30d5b36

## 3. Inputs and Contracts
Input: Profile metadata for import_search_engines().
Output: Script execution status.

## 4. Execute
- Write import_search_engines() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "import_search_engines()"` or `bash -c "import_search_engines()"` depending on the environment. Expected output: success for SearchEnginesImport(SH).

## 7. Done When
- [ ] Criterion 1: import_search_engines() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
