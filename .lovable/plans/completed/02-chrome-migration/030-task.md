---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section30"
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
  tests: "unit test-30"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 030 — Permissions and Report (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for PermissionsandReport(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
chmod 600 on files, chmod 700 on dir. Print summary of applied/skipped sections. fc633c6e-3e51-4b8f-bf9a-26ad619f5b32 d672b849-233b-40c6-affc-62937e2c7094 e82f575b-4487-44b1-8e33-c3bf44f7087f 39799bc0-9533-4686-bd03-d1a5b0a8a590 042f9d3d-6573-4db1-b714-f68cfbb2ee7b 4f710e23-d97d-47ed-b189-e8b2233585a9 be3db8db-42e8-4d54-8df8-edd3ed7ca0c9 2e9f1f49-2b78-4fa7-a40b-f7b0f79c69cb f615b082-cd08-4710-a2f1-579d01259da2 1f80a3f0-5ba9-4c65-8852-9c066a0d2117 d948c172-c6b9-41a0-93e7-569d05dc40b1 5c336277-bde4-493c-a03a-6de73971907b 34d27073-fbb2-4009-8096-dfb6fbe43cc9 450b207f-eaad-4ab2-bd99-f9da6314f610 ca1beff1-199f-4515-a1c0-ee33610dc21c c4c0c651-b61e-46c0-a8ee-993f53113c0f 36ce3c2c-81af-4864-852f-59edc04402e4 4d71bc50-f802-4a24-84b2-5d046b4a3872 0f8d43e9-2e7b-42a6-9c13-c118902c68f2 ac635b6b-1593-4573-abca-ed2417bebbda 96e54d79-3c0a-4c25-b612-706c1e3a6bb0 7262e760-914a-47a3-aa72-673291424299 fb718329-1947-44a8-8e66-208ed997b1dd 0d30ff64-81b1-413c-b266-1cd5e2f0715d 6156c775-0b9b-49a9-aee6-3086129a380c 8a7416f5-0dca-4f4f-beac-bb4870189f44 39dc4778-d543-4996-a5aa-5144063a5121 5a9f2a09-977f-4dde-9fa5-c048af1dacbd 30cf5359-6070-4a54-a799-e14f00361890 4fcaa587-f51b-4e14-b887-fbd85a840008 6c1f2377-332a-4a34-8257-84866363dada ece8f37d-499a-4875-8c14-6e7a79d8ed3b bbbcfce5-e85b-4280-86f0-53944bebfa44 3ce9ff80-eff0-42ae-9cfd-a329af60304e 0b6a951b-8362-43cf-9d10-ec2b9ad9ac46 70c00aa9-3eed-47ab-b0c4-5fd6d86b3206 5328c0f7-e66e-44e2-b811-bc6834776ff8 bce6a220-3661-4036-9335-ad95645b5d4b 519c09d0-b29f-4226-86d9-120849574922 18322643-9a44-4615-a7a8-fc97957581b1 d687242b-bc2a-4ebe-b9b6-e09cdc259113 15f55b53-dfae-4113-84eb-9c2409c1b485 e44171f9-67ee-4bdd-ba65-3aac8f0ccb11 8ae0ba68-a956-4c00-ba7f-ec261d379e34 c39b54e7-ed97-4aea-9826-d8d6bb56b6c8 672f6984-7a2d-41c2-aca0-3afc586bec79 5a288dc3-f337-4ee2-927f-0f3f69ce3ae2 28249731-1046-4e53-9a55-28d6b299d926 b4c0216f-96a2-47a0-98e4-24c54a2e7076 3994a80d-874e-43cd-8de7-7bea9b9700b5 18cb712b-492d-495d-81c1-d8d33e3c51f4 a7e56b46-8909-4e4a-9032-69885cda7079 e4bd0d23-aa7b-49dd-966a-b58305506b3e 531bc1cb-e58f-495b-959c-de206aff6fb6 820a1f0c-0ade-4133-aab5-60d5c6a3d600 abf66963-491e-4a19-ba38-f86c16b81a3d 177ed4e0-f17d-4e8f-951b-82903147e9ca ccf2f100-7c05-482c-a330-11d7ffe5f841 35db6853-e980-4426-99e7-42c0958f8c78 a6835fa0-16ea-40cf-8ba7-f0999599c60c ce306fa4-64ed-45f6-9e0c-bd4662a490a7 64065fc5-c908-4c43-b9ee-c0ec74918e6b 9b5c94d5-dfa6-4c4c-9a90-786f27b84585 43eddd4e-ecf2-4c45-b569-6ed1f899f75f 44b0fc6f-ada0-4ff1-aef8-a3758fa97be4 cec391f2-d1ad-4638-a841-4cd89ceddb48 4c6fb661-e67e-4fbb-9c27-e29b2db59091 82abb046-090d-4633-a0eb-f6007d8bc5fb a5f04945-6592-4f61-ad63-260a4b44af4b 29d03006-1467-413b-9eb7-a49933cb2121 521c469a-96c6-4f29-9842-0bc3b8750341 f7b5db8e-0cba-4956-9145-c11c5064ee57 aabe357f-1e82-42b5-89f2-59181f40ab46 7ca9685e-0416-47bf-b964-a46baadd3612 d03bd3bd-c3f2-4f5b-b617-0809b9ea35b7 7e04e79f-cb23-4e66-b366-e258f2e4773d a2100ba9-d477-438a-b9f4-269aa0c27693 70ad7f70-f07c-4b53-97a5-e9e0893e22e2 f6ed8d77-1e82-40f0-84d3-ade908d86e4a 3c1252ec-9105-4525-80d8-8a40b12bfb6c 1897ad1a-cf53-41f6-a48e-c17cc76d455f 1378a45e-5716-4cf2-a659-cff251374a68 4909406f-f760-4612-96ca-ae3563c3662e 04305d5a-85c9-4260-ad40-beeee1f83e66 20b981f4-764a-460b-88d2-98451f7dae5f 17463940-633b-4268-ab41-5314d81dadaa f588268a-2a20-4400-9bf5-9c3755de917c c6623f3b-9a14-4951-bec6-418f6eae6f0e 5181f026-b775-4e50-b39a-cc5f565a989b abfca596-cea0-4b49-8f8f-b47dfebe5c63 bd75a914-2f8c-4a06-bb30-7e44f8271eab ed305ab9-3af1-443a-a672-d92118863688 ecb45b95-cd64-4d4a-9687-b5d894075822 cec29cd1-4379-42c3-b4da-c545493ee8d2 37ed245b-1656-43af-aa78-4403f32ec0eb c2029239-ed14-432e-bc2e-66c0d30bb880 ec9f7736-2221-4168-832f-e56a33181d1d 83d3d6b8-baaf-44c6-ada5-acb3413cd31b 3c84856e-c771-443e-b669-639415ffc8e3 28e2fdd0-47c7-4e4e-8a66-16d1c95995da ccfa90c3-0926-47ff-bb1a-a8714c6623ca 0b71e8fe-6363-45e9-97e4-79ec4b7ae1a6 3c5a383e-3507-4910-a9b1-cbc9c5e0cf55 e0b79ace-a08f-4d91-8d64-5cc18887fb75 0b30d3cc-63d3-4dbf-852c-40424826d73d 4affc39f-38d2-4d45-a56a-93f5ae48afdb 11781397-9b8c-4f72-bed7-ecbb56bfcab8 16b17aad-e425-435d-b053-5e0902597595 93283413-ef96-4927-a235-b6588a3feb0a 8cfb1f0d-7192-40cf-b33c-f28a0d666db8 ab69ed95-1235-4c47-a39e-7f240593aea0 526c06aa-7232-45df-b8ef-9e60d3450e00 088efbc7-4c34-4551-bd97-6745d77d7351 4c768712-14b3-41ea-a455-60cea72a3249 6070cbfd-6210-486f-93dc-8437d1fc4f7c c648200a-135d-4e16-a3a7-f7912d588c80 ffd9cde9-ff4c-4822-b3d7-2aae5ebc6dc1 f6864377-0bec-4086-90c0-6aef0cfd6253 93bac6ec-8c4e-4297-bae6-3944c084aa3d 25719efa-2610-4b96-aa0f-1996e05af524 e7c22bac-655d-49f9-ae57-afa97982db38 1f0f2612-1acd-4307-93fe-073b9f3d9ff0 35105d24-bee6-4a36-a40f-07f8b0425de0 650d445b-047f-4c67-b4e0-bb82a4c4a3bb 23539c8e-3bec-4c5e-a13c-bf1dd8cfa5d8 bf81234b-7425-43a5-a2c1-f48c1c958eb5 0d79c5ab-318d-474b-b7d1-9401f816a7d3 9639a16d-b8fe-4f62-bed0-fc4ed5173f43 93dc416a-96dc-47fa-b839-d11539d0c8c3 4e773eba-58b4-4075-81f1-6cbd2d2ba2ce a6a2728e-e7df-4a94-958b-5d4117a49bcb d15a351a-b5d7-4cb1-9b8c-5de730c099b3 9b46bc30-b175-4157-ab90-4af0ea11c6e4 948a75f0-ad26-4e85-a295-94a0174e2bf6 807a4783-7a87-4257-8b49-3a1ebee5f5bf 5857fb52-55b7-4bb8-b7fc-c7426523b62e 9a2b3d37-d85c-44f1-ad05-678466dac7b3 0ef55bed-c8d4-4d27-aba5-2695ba39fae4 20dff468-30a6-46ce-8f74-966db0a2e70f fe72d4be-ba5f-4eb0-942b-714f00cee4a8 815b90f6-aece-4516-becc-33fcc0174a25 96e46764-198e-4e8a-a57e-b44adbd92e0a 2427ce57-bd09-4c8d-aaa2-9524e566b59a 33f70201-6d89-4a45-8386-3c6ac041cc14 da87aec4-092e-4e55-bd9a-25a44da755e0 cf38e7db-3b36-421e-a6ac-6fb2e79c0cf8 c26afc09-482e-45fb-8620-c3bfb4cc644f 782d178b-cb71-4f41-b7e9-c247e919ea23 bd212a99-dfd5-4d03-a054-ccb16502c5f5 fe0078a5-3d29-4f5a-ac69-a07681d1b541 2ef40d06-849e-40e4-9ad4-0dfc57b270c3 21ea4525-24cf-402f-b1ec-5c162cc10251 3ff3d9f8-d6fa-411b-bd9a-c3a15f87ee5a 080b5e00-8df5-4523-9505-7e788cb08c58 16d97d46-c05a-42b0-a5f7-d0442007e16e a1c13eb2-8fbf-410a-ad25-9370b8ff63dc d4df1614-de8f-4a6d-ad5c-1ddbcd33bbfb 594f9f04-5d69-4d85-b6ef-72babb42d12a ff8283fc-b79f-4159-9f06-e9a297eaccdb 6766eb9e-e394-40db-bd88-376f48f110de c77c2b73-856e-4117-94c0-b2bdb5f53075 836398b3-62d1-4f34-bd6e-d5f9635850c6 49bb32d1-adce-454e-b228-0cb0e753077a 7dcba94d-bb4d-438b-b9bc-8bd2573bf84e b7c6cdd9-1fb8-4ef4-bcaf-116356aed7bb 8bbd0a46-07d0-44a6-b19c-ee4566aa2fa6 5ba9d9ea-2ba9-4e03-8079-f27c0f5c1bed 7b520057-18ae-4ce9-9e18-7cf99ff8ffec e2021454-6e99-443a-ae40-700238096d43 d1aeb9e4-7f1d-404d-bcee-e350662ed7b4 69ce526f-e59b-4163-a60e-4e3bc6593197 5c57f52e-692a-4d34-8efe-17ba28c0eb58 09904205-5445-42ee-81b9-d6363e7b3ab8 d512aa10-49bb-4647-8763-c89724865a91 67a8ad50-b3b7-4a41-acc0-35548b9b552d 7556dd04-1b7a-46cc-94fb-3884945c7635 7c384461-63b4-4dd7-9024-b3540eda454e 000465a0-b3c2-4643-a207-3d8f2e98fa78 e27c927c-e5e8-4b9f-b97f-c9e97dab8703 be1d4d49-d098-4822-9787-dd7f72ef2c21 1a4782f8-4142-4642-9c94-9793a16af315 081fe643-1117-4757-96c9-79fbf2f4d76f 7775f62d-641f-4370-9f6c-8da7b6d6003e 5af43562-2ced-45b9-98f1-f1794c67c15e 1b615c87-041d-4ef6-8c77-430c15818381 12c38740-8425-49ba-8219-3bfd42e74408 3a628f98-cd98-4a00-9c62-61555f51f284 54a9b737-2f84-4105-9d26-e6a2cdd21361 bbbc0ab7-ddf8-48c9-b9dc-c0dd4b19d9f8 00d9a322-427a-493e-ba42-d7de770b3db7 ff15952f-fb9a-442d-a0f5-c99688d12179 2ee9f66f-f3b9-4ee0-b659-2bcfeb8e7ef0 b1761e24-0963-4674-a66f-da3b0735917a a75929d1-ba53-4578-8d91-283b84653e51 8e7c4638-639a-48ef-9c11-5651881642fc 0f34efb4-e9e0-4d45-8fad-e93ee047002b 882984e6-971b-41e5-be31-7899e83ed6ce dd39fc1c-2131-4c11-b2d7-41247ffca3d8 cda46646-bfab-42fb-b608-8e52fa4d10ef 93522684-4c27-4bff-9b03-bc10df440964 7206f50a-d0ac-4d15-bd09-5e8f2d31c43c 917f0cb6-4299-4adb-ba39-fc7e23bdd019 87ae8fca-4ae4-4919-ad34-771b0b656350 00b8ea85-41dc-4a67-b847-b413e8c11900 9ad2b48d-8b80-4dda-8169-d4cf31e875e6 6b3d7b43-2393-4507-a3e9-cda8d5c289b7 85a88558-1788-4c7c-aee2-484466663f02 1232eda3-d67f-4118-9997-686461dab3a3 74446452-7802-49ab-aca3-93400d3ea8f1 7845f135-4a13-45de-9605-aa772f7717e3 7b0ca127-971b-4792-942c-29737fa3d257 0adc8205-73bb-4bab-a43a-07dbaffc4286 4bdd01d4-947f-4922-ab6d-297b73c9b7e3 e27f84d0-b241-43c1-b164-4132541ac89d 80223512-a0f5-4977-a831-b9e26ad3b47f 4cce21ff-8dea-4d67-894f-37c7a4b48349 096afa2f-778d-4daf-b7e3-cfcd1ea6d35f b4a1169f-461c-43cb-86e8-f9009c7a7c60 a3303e2e-cae6-419b-9c11-9cbb8121479f 347c9b5b-6919-4129-af87-c46a94ced3a8 c74f585e-2359-4d03-a436-f8050d812f9c d5d3ef60-5379-4cb7-b00c-fc2db8fff295 7d1e6e3e-b95b-44fd-bcb8-c99b7162c80f 903d4dff-4910-4fdd-b7b3-dd8d8e6ae2b2 0cd2bbbc-8583-457d-850e-72bcb4be43ac 0185d2b1-e451-41ac-a322-cea37f9f046e 6db97b19-f56f-4138-85bc-b5b9d162c1b7 4fbaabf0-ae8c-4b91-bdf4-a9e164d86696 1e44d60e-07fd-44d8-a787-334831c3c1d5 d0fe64f1-3612-48d6-baf0-cae376cfbe8e 7ebe7c29-7e8b-40ff-a8fe-af1968ddc049 87ad5b24-e0a9-4cd4-adb8-37604d44ba7c bf8aba20-1460-47ee-a6ec-9380fbb5539d cc877ecb-48fe-4e84-972d-7dbfcd7e67f1 00c8c3b0-0f28-422c-aab6-c0050c734517 5be8856e-80f6-4eb9-8bf8-a7a35d777ef4 aafd488f-6ca3-459e-bc6b-7369e4180b42 31f785dd-ec70-46f4-b107-c85066ae624d 429cc693-16ef-4a4e-ada3-f88ee3acfb3f 4b2467e3-dd64-4542-ae0f-505215cc98a6 52ead44a-5014-4510-9815-a608e0faea4d b412033b-5190-458a-a97f-00e60af2c992 c3645aac-f8da-44de-a92d-cbc00968bd5d ca30b420-a06c-4337-bb41-368356c3f2b2 19193f96-9f38-4ea5-98ef-aeb9ecdffe36 cadbadd9-d563-4bcf-8726-dfbd134d5bc2 833f8a71-b6a3-4b12-9266-28cf1b52ef67 f0d1ef42-0453-487c-b47b-77371d409e87 ec03d43d-352f-4857-b36b-ff08a608c4cb 16415775-2166-405f-abcb-e2738d45a033

## 3. Inputs and Contracts
Input: Profile metadata for set_permissions_and_report().
Output: Script execution status.

## 4. Execute
- Write set_permissions_and_report() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "set_permissions_and_report()"` or `bash -c "set_permissions_and_report()"` depending on the environment. Expected output: success for PermissionsandReport(SH).

## 7. Done When
- [ ] Criterion 1: set_permissions_and_report() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
