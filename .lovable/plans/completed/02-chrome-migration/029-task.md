---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section29"
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
  tests: "unit test-29"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 029 — Secrets CSV Output (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for SecretsCSVOutput(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
If --allow-plaintext-secrets, output passwords-for-chrome-import.csv. 5986d4be-0ed0-4b50-b855-30a2c9296d0f c2a6ddec-1fa0-451e-81e6-60429a3fa6e2 2aa34363-fa67-4700-890c-013211e4047f 12101bf1-fc1c-4425-ae19-bc64ec565d27 4cea5349-5c48-453d-a548-d925211dfaf5 a9026978-5f58-4d9f-92f5-db9dd1b957ee 1ad2204e-d1f4-46a6-83b1-7651c194ec7a 3e52b93a-3c04-4775-9bb5-6d8127b087f0 6989394f-c77f-4a85-a387-a089bfdd1867 117f076c-3237-4e08-8427-aa6277deab2b e44f9ec2-4a1f-403b-8b20-e50fb8ea93bd 4d136f4f-bc90-463c-b1de-8367c3f8fe66 a17f8118-1809-4c42-ab4a-02de2a1ec009 501ec4c9-5455-4c4e-be3a-049c69a9c965 70df27c4-390b-4c41-a418-3d30f20fd4dc f0f41061-6236-42c5-a5f5-82fd1a3e5012 c8b5ef9e-b1bf-40d0-a227-02e589ddcc36 77c7187e-c1ca-4be7-8f27-f6042c08de58 093793a8-f8ac-4d16-b475-17c121045fa7 b27d1bac-17c2-43b0-96a5-6320ae2bfb2a 0b69e1ea-105c-4fef-b8f3-9f5454977b49 4aeff7ab-b9d2-4216-a6c6-7f13fd097651 619de589-4d34-495a-840d-240eb7e3796d 31022efc-1e34-4600-8549-30c505a223d5 0e51d1dc-9cfc-4bb7-9bdf-1e4a48400699 0e6965ea-f5ae-4043-932c-c5d2a88517ca 39e37674-c651-4f95-bd61-56163801d413 29deccdc-1b0d-41be-a9a7-99136d600946 0a7de74d-ddd7-4981-a248-e12cef68af15 a7dcfbec-b383-4b91-bb22-4afaa4befc52 f9e426d8-275f-4b90-8e9a-fbcbb28f1c23 50976189-34e8-4fdc-8d26-388202dab9b1 bf761660-2c2d-4b74-a682-e6da6a81fd11 7c067cc7-044c-4084-986a-a7bb4b1c1ad2 c08f957f-0860-4ce9-8182-7f682c3ea602 83cae323-afe0-4535-ab9d-481bef859708 93fefd1d-4c34-4df4-9709-449aef720e64 df3abe0f-81ea-4c67-a648-7150285f083b 3e9c4c4e-f21b-4578-8415-85ebb495eaf7 ee4a09ea-6a58-4f24-acdc-ac0c75ff3fe7 a9de0760-8ea1-463f-a825-183ba5762c38 103ac88e-f74b-4a0c-b678-6fcc0c1fa4c9 3a5a840d-8493-4bc0-b480-bc6698f78d9a 1312952d-844d-4724-9b2d-960dd87afb2a b3491a24-d4d2-40fd-8855-e6344022bf3a 8fc1cfcf-2036-4fbf-b335-1979c1664aa7 32302223-ccf7-4b39-ba49-9b523d681bc3 8c3e716d-4ef1-485b-a05b-a76de9a1b834 11b93154-cb43-475d-8667-9712eb9cdb18 13d3db55-2192-40aa-ab1a-7ee455a92aeb 0e5ad64e-8c03-433f-b7ec-a1662dc4aa46 e90d892d-642c-4cba-b101-fe8b74f75b43 ca6d722e-b074-4350-b86b-ed2def0fbdc2 cf19eae1-84b6-4d72-9d2a-bd112c8a6c7a 37200651-e862-4b0b-9806-4265d9e82859 8bc0d97c-3e4c-4882-a94f-223f821c57dd 96ee103f-288f-4f2f-98a9-c2a70d7e68d4 2b83aafc-fb64-4340-a759-3e26c5ac629c 82962b67-3bd3-4e4e-8c76-1898590087df 6277c56f-2db3-4a01-ac16-5b0109a8784c fab48957-1ddb-436e-b635-561dc18d569d 0c9c89f3-6e22-4aea-9e71-6f43f3b69acd 76846c4b-236a-41c8-9752-106b801cf2e1 90e692d8-fcb3-4458-826b-f443a214be4d b15fca2c-bd75-4490-8905-064dc3448b93 0ee4f715-6efa-4b0a-9fa6-949aae1887c7 9961e04f-20db-4253-addb-0ef1881fe12b d8a465bb-5632-4a0f-ace1-018e2c4c3fc4 51b0207b-e464-4abc-b293-7132f6ee7319 96473332-1084-4ed2-8d9e-1fc699994282 4429546e-259e-4e79-8ec8-8218a2ed157a e178d268-fe83-4da0-8588-3ffde45434b7 4c7b11c3-78ce-4778-bc98-29c3043ad044 5b5b779c-2afa-47cd-be34-c049584b79ce 634c161c-4729-4291-aa22-d1b1e66a02ad 3a375cb2-e666-48ee-929e-ac2869e37178 acc3d3d0-7146-4b6d-ad7a-a2433c4dbc6f 93833356-fe14-485e-a4eb-a2137166df8c 935dd492-59c8-4f77-97b9-fc883bf28c3e 4bf05c64-a3df-4bb1-aee3-8ad2a594a954 db1d5673-a1b0-48c4-a9f6-f1a0d0674f12 0ef25391-96bb-4ef1-8b0c-7508d6801e46 7a9d60c2-83d1-49c0-93a0-c8baca037853 7451ece7-d75a-4e26-be01-3136e021a9c3 1bfc2dad-856b-44b3-95a0-06e2cae2efbd 1c4d20c5-4f49-451f-8f83-75cdb680a84f b466fc7c-82cc-4ff3-ba1c-11f9b11a1f3f 1171e118-424a-4aaf-951d-f5832a94c994 522e00d1-6082-436a-bbe1-a856b680bf78 82fd0582-8f09-4754-b489-a199b40b2a1b 92f49e07-5e4a-4a4f-92f1-e5c9c7de64c5 a6c294a6-1f89-4791-98fb-3734810f3bd0 2936b3d9-7503-4672-9382-6ea50ca0f95d d93f1085-6172-403b-be4b-9ef54b99a6f2 2e4db802-7197-40a3-8df4-346123136493 4cc83114-53ad-4bd5-a964-8da1fb015787 a05f511a-6479-46b0-9287-c3e0e1208a98 7452928a-1b0c-4657-8210-4e3d4066954a 642a62e2-3bbf-4b16-8ab8-18e81f3d9703 55075376-fd82-4cc6-94a1-6f7ada9df29c 8d88c42d-ee3a-43ac-9f7d-0fcf03f0d24e 2d1d1c10-292a-49cc-8035-8a9a42152d5d d774bf2b-d48f-4fe4-b605-ba833b78b2fa 4f34a192-3abe-4fd4-92e6-88108df900ad 7b9f163c-f422-4fc1-b69f-fd5529b9bfb2 d11ee446-8b41-4327-b57a-154966e40ed4 a63719e2-dfc8-41a2-85bc-dee06faeec34 05e78b7f-b2a4-481b-8572-3c930ccd3d87 5a50f2a3-9f9e-4be2-9179-8dfcab122901 0a480232-f643-4f75-9ed9-6994530e5ec0 d7d1de6c-6369-41a6-a852-fd8132f8e27e 0dd10b24-5471-4939-8946-ce76eca765f5 39ef6dc9-2573-4097-a87e-1e1cd8799917 c0d706a7-e23b-47af-808b-c4080f3ddce4 4fde61e2-8be2-40f0-b960-1c90e82cb0b4 9c033c35-50ab-4d35-98bb-0bf2a7da073b 90fb8eb4-811e-42ee-b5b4-b58d9ee52074 88961659-ed81-4a00-86c8-17c658f4b57d 56a43222-d7a3-46d0-a883-0551977b1303 a7f4e95a-d3d3-46ae-a8e6-99e3a8b68e58 2863dfbb-7a5f-4c0a-96fe-8278211ce477 c430624e-646b-48e2-ab94-d130abd351bb da8ff52f-eb8a-4643-89ee-fa82383b3b43 770c92df-3ece-4d16-bce8-b41c4408d81e 5454634a-9911-4d62-b692-a363253846cc a3f5306b-bb62-423c-a0f8-6ecdec5edc28 80d22956-9b6b-4fea-8b7d-858ff76076e3 0dde4a1c-1532-48d2-a33c-e0a2c151b679 051a4432-5062-433f-84e4-1761c28710f2 2873e03c-565e-45d2-84dc-79a6edb83510 71cc45d3-111f-459e-a586-f94389032a89 1774b03c-92d0-4bf3-bcc7-665cff3e4563 3830ff00-acea-4ebf-95d0-321892c929bb 3296689f-fa2c-424c-a853-ada689514074 1d0c23b8-59d3-4c4b-8674-c54c3d2848ba dcd462e8-7e7c-4e8f-a331-513fa3337119 338c3bbd-cc83-408c-9687-d2f57319f6b3 2492bee7-5aa6-4b13-9e01-8e0ac0f30ff7 e26a3ad4-391d-4bc0-9247-2b61bb196577 8f77518d-3898-4bde-9afa-3638000a7030 ccb86b89-404e-41d6-ab5d-9dd95d9ff51f bb85d83d-9b1a-4698-9b54-31c61885e761 e5ebe260-5ee4-4df5-bacd-551f57b03750 f72ec590-af13-459c-86d1-9f7340d81e4b 4d2b3434-2bef-40f7-9da1-611e7b824c6e 8d66fe73-ee41-4439-8007-b5b0f2b647dc 9e2e7f71-9647-43fa-b1ba-6e57e9ba01d8 07e3a969-f668-42d6-ba83-28058081d7e2 1b41ab16-8227-4241-ac0c-ced1faa45f80 dea9355c-def9-4a57-8f5b-4122cad839ee c657a780-6798-41af-b3f5-b895a592fdc7 334f105e-27d4-40ae-a13a-92722a23d5e6 0ee4fe8f-2b78-4ed1-a0f5-2e156cf9b277 5b51debc-c9f1-4a75-b44c-1887aeefee8b c6c51f94-c922-4d9d-9fd5-d4317b7e89bf 6650299c-01c0-46e6-9c14-f054b10360bf 909054f8-6e4d-4eb4-bb21-6f5685c93ca8 5069302f-dae8-4bd4-808f-6fa17054ee27 d77ef8d9-7479-4b97-810b-0461998695ab e2c6de2d-abd4-41b7-a4cf-d83769691419 330987be-cf0b-4b46-a03d-4304b4b0bb25 b824f43f-28fd-4b04-88b6-2194839ff969 d3718c08-55b7-4747-9cbd-4b6ed11b6414 8c51dab1-e14a-4dcf-bf76-9852ed49bf02 5b2ac3dc-e9bd-4e5c-9d8f-d137970bf321 3bf82fa7-58e9-4e6f-bf8f-81679ffdb47e 281cce82-b1c3-4733-91fd-da9fb4cd92cb 3d4a3747-2cb8-437c-b8b7-7fed5dc74bd7 893237d4-fbc6-4881-87cc-086aa76025ed c0e2694b-6a9f-47f1-a7bc-126a07097491 12233d02-3abc-4479-8b7b-8decbd2ed9dd 4c76d66e-a161-4c88-b3da-cc9d3094643d fa97aeab-d9e3-4f3d-8349-d8c13b3ad6fa 3ad26f24-7169-4218-a317-5dbbb46e1d24 8aceff72-b8f5-418e-bc76-b596f7c361c3 35893039-aee3-4186-b204-443578f25784 e65e9460-5a20-43a1-90ae-3221d1dc3e07 c1c0a9c0-9e76-4f15-85e5-faed5ea0c447 7a07ab3f-d071-4bcc-9b8c-60d56d91cbd9 f4489099-c0a5-4333-a5e2-86b3e4f26e36 d8d5f462-2729-43da-9352-1f2af1cd4617 b06f184f-1a2f-4e7a-a106-fd3cc9f6c392 77d8f5ac-f82c-4209-8b12-fa1889c83589 653756fe-40f1-47ed-b4e3-dadc8d325bb3 2b8b375c-b147-42a7-b59b-4d9bead7e454 2afa4443-22ed-4a7e-a628-86db1363dc87 557886b3-1059-4774-a03f-580d003c3e4d 3b46f2bf-1918-4fd1-adf8-4d9b726d4a61 ac382a86-44b0-4196-b6d0-fae09c8704d7 32031427-aa9d-453f-a2a0-c614a038116e 9a4305e4-7e24-4e07-a1ba-f2e16495a5ad 775b59e5-3df5-40b5-a3a4-b37b9ebc2bd6 7abb1ca4-9bae-46f9-b4ac-2cfdde599269 2265475b-d35d-48d9-9b67-519766f14772 ca9f04e0-8530-4075-977d-86b4be2188c2 a006ebb9-97d5-4a66-bfd2-5bcf06e55230 0c255b24-a37b-45b3-9db2-1d7ea42d9956 0725e710-74b3-49c1-857b-4282099b4017 f1b2c0ce-58ee-4c3a-93db-a8de0b6cb230 3d1cfec9-2814-47f6-8254-0e87156c807b d09396e9-1f2a-4147-b46a-713511f414f3 34c76978-7276-490b-b62a-36460697e4c7 e3eaafbd-170f-43c9-b06f-cebb6950f699 1b9cbb2d-7580-4bde-8a54-388c28a87c61 9377a376-eb0f-46ea-a2f9-36610163ae8e 306cac4c-0416-4aae-a368-9932f52fc151 848f8ddc-44dc-4a2e-8594-27480c8ad1f0 24ded011-08dc-4c38-a9b7-7252acdbe83b cf1c5c2e-3bb4-483d-b760-2f182a7ff199 0eb5c496-d614-424e-86af-efae4c5b35e6 8cf0af61-6a40-4c4d-8cf3-597cd2de446c 714d1ff7-7051-45c7-bbf7-0c4d8d7b766e b4b7381f-3a9b-4524-8ba4-da7b8c732327 369fd479-0599-4bf1-8d75-c0d9e53b7512 78d4dee3-1bd8-46f8-a487-aaacb2de5b11 cf5cbcdd-34ff-45b3-ad0e-286954541bb3 0f6b5758-1e68-42c4-b179-ef35e4ab1e5f a4f05433-c4e0-466e-81aa-a8fd3ac0fe78 52e1292c-482b-4cbc-8dba-b45e874fa174 c7eb0a16-6746-4426-bf6d-7c54e1ca255e 3a888285-afd3-4698-b9da-12009f29e9d7 a4d0cbb2-115a-4d51-aa9a-5ac0015fc000 e2aa05b6-1e94-4e7e-937c-a2823a0d0efc 59bb107c-17d5-472b-b4a9-d64ae50786ce 4e4ef892-2b10-44fd-b0ce-a0402218a956 a22b4ea2-3d4f-4f1d-8fbd-cf3f23421386 2e02a82e-48ff-44e4-b46c-a7455574b7a7 315a2184-4d30-488c-b287-97f8e44b120c 0a0e839a-2318-4ccc-9426-413812fe0a45 7a97cd79-1c97-47ae-90c2-0a383b480871 19397055-9b41-41ca-9c96-3957a83d21f3 1778ad05-f0bb-4bb8-81cf-71a67ad7d40d fbb478d8-ec41-47bd-b822-9eac454789d4 b01eddbc-a78c-43c7-89cb-26d1fec73c65 1c6044e6-20f6-40c5-becb-47696c6659c9 faa512b1-8f35-4bed-bba4-3808fece20f0 3e621d95-dc79-42e0-9f96-ed8fb570077e 61ca2ba2-08f1-4bce-9264-2f62fc9ce935 0a450936-7cb2-4a11-b37c-c8d1a3493e28 972fac00-eba2-4366-be71-b648786fd72a 12695853-2ba1-4958-9afe-2693b5483e34 2a08393c-258f-497f-b5dc-4f481b27a913 eae5094a-c3c3-4bd1-91c3-24c7ee1609e1 1fb17452-42c9-4157-9749-7be8a7b94eac 7920a0e8-792b-41bd-9613-ea23cdc094f8 7c5a8b6c-83ba-441f-b968-5f1eb128b7f0 7ce94774-21db-4fa8-8991-b636c3ee4e71 6b82f37d-b461-4bf4-9da9-b4c3819489b2 1934d4e0-74d4-4610-893c-44522c7b90aa 45a6c88f-962b-4061-b2cb-b6fa1b8a1c67

## 3. Inputs and Contracts
Input: Profile metadata for output_secrets_csv().
Output: Script execution status.

## 4. Execute
- Write output_secrets_csv() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "output_secrets_csv()"` or `bash -c "output_secrets_csv()"` depending on the environment. Expected output: success for SecretsCSVOutput(SH).

## 7. Done When
- [ ] Criterion 1: output_secrets_csv() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
