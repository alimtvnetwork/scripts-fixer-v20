---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section7"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/08-file-folder-naming/powershell.md"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/powershell.md"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "spec/21-app/fixtures/chrome-profile-export.example.json"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a — no db"
  ui_surface: "n/a — cli"
  tests: "unit test-7"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 007 — Preferences Export Core (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for PreferencesExportCore(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Extract homepage, session, browser subsets. f181cf12-e8ae-4c36-8644-8b8b0154628e afd1f4ba-98d2-4d77-8aa4-a92407c042cd 0ff6a31e-770b-445a-b8f7-7e06903b8665 d1be30c3-61ef-4e81-8e83-ea3cd3ab8848 48bf5dbd-117c-48b8-bc4d-dd3f3c2cff1e 251eb610-16e3-491b-b662-5a65639c2bb7 02fc4db1-5946-4b50-9853-e7cbd7656caa b1f346d2-35d6-42ad-9337-bb4e9c23d91d b9cf94b4-b4b2-42ab-83e9-26820fb7036a dfeac4a1-9ebb-4783-9cee-68e9d89641d7 cfcded86-06ad-4e9c-877e-6e4d507d1b77 06ffe162-a039-42d4-8166-d1417a4cd4c7 7ac52fc0-feef-450e-9c3b-982fdddf7c76 3a7703bc-10a9-432b-8062-3048481831b5 102170e3-edd5-40aa-86fd-475122e5deb2 f813fd28-be56-49fc-8822-9a3efa8b90e3 e8e65ba9-b9a0-45f8-b086-a96e26ee8905 dc2d92e4-d8f6-40ae-8f48-6bfef2eda773 cb9621b1-1018-4a59-b980-16c471c1e417 0cd3d760-d933-481b-a45f-69145a71484b 9a7f98f8-f2ee-4274-96ea-dff80427dcc8 d9ebc3bf-a9ab-43af-969a-ef592dd46154 8fd66e8a-6a68-48f7-9397-04f23224b48d a051b6db-49a9-48c8-8e37-d9f066429df9 88847ba9-8369-42f1-a2b5-8d9f49369e87 77452929-9800-4d4d-b12a-b51a57fd662f 273d9973-2863-49b7-9dee-2ffe16ea9069 50b3c5b9-bcbc-4091-83bd-c96b37107a65 00e4e4b7-8b1a-4032-9d91-ef3156b49b60 1557e1d7-0399-461e-925f-7924bd72baeb 08718bc5-8a63-43db-8137-aa538de74ed5 b2b9539f-520d-45f6-9332-cf44693123f4 0d55e164-b1da-4ac3-9e00-c56100a78431 9e7dab16-17fc-435c-b954-6ceb42a53975 2b7feccb-fb0e-43b6-97bd-090190c3cdd8 cef30cf8-c12f-456e-af71-73e3676f86d0 19af6d9f-aa52-4b93-aac1-15e0fda51fad 216138b0-e528-401f-99e5-37035e887df1 e8577004-9592-4458-bc0a-3b13731b2cad 3ef57b00-ccb4-47ce-9a9f-ae296ec3dad6 7185bfa0-fd70-4271-8597-1baaae9db962 3b260e91-055a-4a61-9e36-1553b0a6f983 282ea213-20dd-436e-9b18-7ed8ff4736f0 c99215ba-f511-4317-afe0-b48354fd5993 3c78e0b5-0859-4923-991d-8e50072aa91e 36a1f41f-eb12-4ff9-8405-da25612dcbd8 88be7eb5-9caa-4b5d-9092-bd5b45783ccb 19b30312-6091-4007-9fda-657d8542707a 02911c12-f685-44d2-8ddf-1dad973099e9 a4ba961a-23f8-47dc-81f9-63c8e613d085 590d3f1d-2ef4-4614-9b61-d070fefdeecc 9a6016a8-6d27-430a-8983-ae296a401599 b8f60941-f251-4d66-aa8a-393e1623ba45 c6650839-5e4e-43c1-9139-78eb4dc5361c 84b39850-91cb-4af4-b26f-90695ae763a2 f50035bd-3d8a-486e-a863-058fac424373 3c8440cb-2580-4a39-a579-17f2632640d0 084bac68-9c62-490c-8da3-aa3745461404 be257077-c8d3-438f-ad1b-9aab05d3800b 623d4212-0ddb-4be4-aa8a-f5463880e75d 653cb9a1-0d1e-4223-bbe7-304215a00b1b 3279a8e3-a824-43cd-81d8-ee86b9782ed3 3f6e54d1-8339-43ad-b766-a99310a2af84 5cb95d85-a6dc-454e-a900-2ecaa4f2371c aab4c9bd-96f3-4e81-8483-f6b2482b9d7a e5d73537-b183-4ed4-95f3-ad9a4fb62104 ba98b2e1-b54f-44b9-8b78-e73247e91900 74bd8256-628c-4a05-b87c-83c794b10b7c d6748f54-bbfd-46a6-a84d-006eedf7fa03 a46c5de7-c279-4b1f-9597-bdef17502b7f bb2927f6-6dd0-45a1-8de6-306ecdd10848 2f9bc4db-223e-42e7-8d1f-eb1ab141ade7 4651dc8b-1415-407a-b9df-f28a1f76fbd5 d1b6d570-2f0f-4922-9eb1-28618a579681 a27752f5-973a-42e5-871b-1049725dde55 9e8221ab-b391-4a70-af3c-3ff48d26256c bd3d4ff2-7fd4-4ce7-b95d-13501485b2eb 379d6fad-54ed-4e64-8352-7d3990182ae2 66935bcd-00b6-419b-aed1-13821699ef08 7b8d4ebb-6ed6-4e75-b27b-4203c3267324 6d9eb80d-8497-4b49-a181-2077855ca59f 65025741-07e1-4485-8176-ebce1e526e15 dbc653c1-191c-4464-9d65-7bdc9476f126 24bf9c51-0173-4bb9-b9de-46fbd8ec618d b3d0344f-ebbb-4d86-bfa3-c799b8903d8a 99434ba2-433b-4ee5-8ba8-e91301230b73 752d45aa-eb79-4ee6-9333-091520219589 8dea6363-a5cc-43d6-8d42-3e1ca9e6e699 87fe108b-118a-46e6-ae1d-014872fab1e8 0283f198-13d7-41db-8c87-89b3c3d445d7 c4c14c87-984b-4e77-8e88-aae469524b7e cfb75073-1fa9-4fbd-a8ce-5f49f226ebe2 e386a654-4912-4053-84fe-a65af1d4fbe3 637f14c9-bab4-4644-b706-a590a3d8efc2 1ef9146d-38b1-44cd-96e8-ef888670c109 45372612-859d-42e0-9bef-019b87dfb15f db4b3a4f-ef92-4fdb-8aaa-4bbcd8ff22d1 442a7b4e-5473-4206-abcd-9ef904591350 dc325dc2-daf1-401d-ba8d-24d38dafaf80 46168cb3-de8c-4bf9-9823-3a7b1f9d732b 644c4d03-f3d0-49ee-a8e1-2f22a1131274 04ac5bbf-9c76-4d8c-85e8-15b42fd4a5b4 52a4d79d-c6d9-4429-b999-b90187fb62a5 2f15821e-f7e8-47a2-84f1-042d0b8a0296 f4206597-7e3b-4431-a06b-a3342b01fa75 2489f47a-82ae-4e4d-b35c-8d0bcf6b3574 eefc523f-0c0b-4898-ba78-35135588d578 7763ccc8-3cd6-4cc4-85dc-4ac7b6eed77a 9308dfe8-3162-42ea-bbd6-5c9fc765c7c7 1a70bc1c-946e-43b4-9f2d-f2df4a8c20e8 efc0aa57-b055-4852-80ea-45d219a95f9c a1112d79-f3b5-4384-a2d5-0b9b86c37c1a 93324a11-b5e3-4c20-803a-8ba0723b84de 2bae8a64-12fa-48d3-ac27-cce71511fc35 21613b5f-e785-43f1-9238-57dc67f7930a a8351a02-9b78-4854-8242-c4fe02427ca3 2e816ad9-a79f-425b-b785-6687a681f2ff 97b13109-bbce-4c0f-9509-6a8f74ea4b2f 72e46340-b016-4275-b8d2-57578ae238d5 c51e2cc6-0364-4ebc-8eb2-0794b85a5568 83b200d2-4aa6-4b97-976e-9f2b45b71e90 c8eec572-e148-42dd-8227-30914f7615ef bf4bdba4-36d6-4dda-9c53-91071300682b 7b3a6d95-b1a5-4dcf-91f1-0f37450cfe27 c72b6361-8fd3-4fde-8705-b91dbfc2bc98 842112b0-0efa-4b69-94da-52fe7882b25f 3b1b088b-b96b-48e3-a479-965f035b8f04 29429871-c949-470c-86b3-e3363c8dd3da af7490c8-1506-4a68-a130-b78bb83c5a28 bf2fcfcb-7500-40a5-93cc-53fd0943183a 9c5ed566-53d1-4447-8503-e9ab76f75a16 291a16eb-5bc3-4eed-8279-d06618fa0d3f cc89f747-852e-43e5-a0d1-9bd9b0b5adc4 c2cf0c26-f1b5-457e-9628-4f96caa11b21 8b190977-67c4-463a-88f9-641b7fb87be0 3e0daa6b-5840-40ba-a716-e9582d62ded5 3288eec6-f51b-4128-97e7-fe9736573266 d135a9ae-7bf8-4411-be0a-5a4164cee15f f04db499-2ee6-46b4-9f25-e2425f6f647b 0a05c99c-392b-403c-897b-f714bbf4cdc9 cdbc01c6-f541-45b1-8828-245a641da923 af09a5f6-39e7-4784-bc42-d5985403dd73 6fba7562-5821-4cae-8258-b0829abf1221 59bbd72f-1e4f-4c6f-93e9-7c41c58b42f4 f5361fe0-2d32-4df2-9280-d3149cb995c2 ff3b83e7-a6c5-4e2a-8fb4-f440e1165c3e 653f9f10-af21-465c-be81-d1fde3928253 d46b312a-c9ed-4495-9cb1-5bc12ab6b29a 2bc5303b-2a0d-48a3-9299-14e3407e61fd 71643a8b-dd26-4ef1-8d95-b7049423ce69 5c5fc10b-1223-4105-b7b5-8d793bc431d5 97d39971-5210-418c-a99d-679c3b968c7b 25114866-b3b4-41a0-9cec-f6e0d0cd6fa2 9b0fe6c6-c7a8-4939-9d03-2f626edd601d b169a61e-95a1-4803-8921-72306c7c96bd e0f9c7d9-4986-4e70-869d-c35a30d73b3d 2beb0311-02d4-4979-a0c0-59777d15bcdb 47f879c0-4844-4d08-8a31-76b2c47b8fff e9fd43bb-149f-4547-8356-e7542d426b19 0123e46d-bece-4e3a-8ab3-fb8447dc75b5 cf8187b5-7e28-4796-a111-fa90e6ac425a b56fc545-d5de-49e7-9737-e642697f4cb7 1aa134b6-ca16-44e8-88d4-413ab1f60026 3a638a50-c1f6-4287-ab78-c8b378414d85 9ecaf297-2a98-46e5-8313-cc38df47b937 9b8576f5-be11-499b-bccd-6d22c80952d2 7901cb29-0fe1-4022-9c89-7e6b2edfbab8 612a2fea-0189-4b33-8432-5f5819fe2cc1 053d661f-4d18-4fd9-b049-5f0f0614c1d3 011f4e5a-d321-43a4-a9a7-aef40bcd790c aeb5c79a-0082-4534-8c5c-44c2489f9380 bbe9ff54-a6de-4558-beda-441e2212a132 daceec58-08df-44c3-9f83-f87d563c6c3e fc5f6a4a-da99-42e3-99e4-c500f57032d9 b678e40a-444e-44a3-91a9-cc1eecb1ae86 c266c737-26a9-436e-b5b5-1cba3cc69258 5dd77f2c-bec0-4321-980b-bbc7c4553b1a afe4339b-953d-4296-aa00-50a531a4acb3 6c226ca2-b8d7-4d53-82e0-3191402cbf48 685e7ed1-ecd8-47db-ac55-a14241fd1538 f37751c7-74d3-41f9-b5c3-54587eef57f9 181959e1-921c-4e85-a16d-acba4e9983c3 9a11a623-b0bb-44db-8849-fbe26d3e5d2c a55dcb3c-13f8-43cf-b542-6377c21477a0 3b918dfb-a91b-4e4d-97e8-4030985abb99 085fd384-441f-47e4-9206-f64e138454bc 56068b7b-7a75-4e9a-943a-4e769254602f 094f39aa-25ca-4161-9961-b707ffa0ac69 fd49bddf-60b0-4087-9c09-64af3aa8feca 71e5309f-63ec-4b42-984b-248443c4528e 4b82fe72-275b-4333-8913-477168a020bc f40088b5-8953-4209-82eb-5ba60b7977f3 2cdc56b5-345d-4edd-bab5-14aa1576463a 4c4194f2-724f-42fa-8b3a-cd10109ad13f a7add511-bd0a-45f3-971b-29da6cd49331 a452bc94-6ebc-460f-8d1a-c61199397d9b 101226c9-dc3f-4470-8326-3190820e43f6 0d9847dc-69e0-498b-b3a2-38a1b3c35612 4f7019c8-4e14-46f7-bb71-a6e2b58bf164 f5a81fbf-fbff-43ab-b8f6-8bdced2a5093 a33cb28f-0ff8-40ca-91fb-e2ffc78ea54c 5742a636-f630-459c-a4bc-75edf68c2556 8d3fd457-05c3-4776-b957-555e6df4a065 bc823810-e299-466b-8083-ce9093499978 ad7b9e25-1b36-4974-aa83-22629f54c21e d45495e7-6744-4ca7-824d-9db767c2b4e1 3b5bdd23-35bd-4f53-a134-0a21b31a057b de190ed9-4a5b-4d41-8427-3e5dfaefc927 33fc7098-05e8-4483-b6c6-9603a41f3292 7fe27d9b-2d67-4551-9549-7204530a6721 d81a42e0-66ad-4977-b366-1fd2b54eb5ef cf12cc82-c60f-46b0-808a-e49c4138204e fcb7c113-659c-4949-a8cd-b3741f93ce36 ea7a32d0-232b-48b7-baf5-0e4ddb02342f b9538d60-ce65-42c6-b10e-a50872dd16c3 4bb2ea09-7654-4024-8af0-c80b97e80f3d e2a7e103-cc43-4707-8e10-63ebdbb1185f 1f917142-37d4-46b8-904e-06ec6e06e968 d6a13d73-b148-44bb-b922-2af1326c4f98 b01771c7-251e-45e5-9b33-d098d71f13c2 b926b521-d590-4851-ab58-c7c094d06180 9ee52807-2c3d-4413-93ef-1b26e73cf19c 54b9bf62-4138-4c61-8ace-ac599ffecacc daa82a85-6998-47db-9a84-d4d4cb3aee77 95dc7e1d-44fb-4489-9318-1c6a04391c85 0f6a8adf-071e-46ab-aaf5-3922a76cfd48 9c4c9bba-29d6-4c04-bf25-202eb1adf3c2 8a85dbc8-de9c-444c-b3e5-4903db0ca400 dde0a9d5-7400-4ab0-b8ca-74d8d446039c 533c3e83-790b-46ad-96b3-1d45dcaf8e4c dafd8cd8-3da7-49cc-bd1f-a75c5a2696d5 9b3bf4d4-e941-4973-9bf8-35a1895e6084 23ddaf5a-ecab-4f73-9a46-4137d1a91a8b 1e4aea6e-2c82-418d-ba68-d8afaa5833ef a4112202-d9e7-4b6a-8484-8753fffe5a67 b54de2c7-2373-4005-afc5-174fdf6d3333 805a17fd-7e44-45f4-8aa7-13f74b7353fe e75cef45-600e-41fc-90b4-44f4321a9d0f e35cbd78-93bf-42fc-8cfd-eb6126aef649 ddb8ef50-0bfa-4b2e-8328-b4ed4e25cbac e841cc8b-1ca4-4999-955b-b14f5757556d 37afe9e0-ac9c-4f2d-a2be-afc72d6362c8 48f7b542-fd7f-4464-b6d3-e3558f849be0 efe5010e-bd08-4331-8c0f-0afb5f4165ef b020cf1b-ddea-4b80-8b5b-a9616b2385bd 688e2f3d-7b98-491f-85b3-12842132374f 7ecd825c-cb2d-43ab-ab4d-554a2c2b6ece 091a412c-00e6-4d4f-9d2c-c3c1f7f3bf4f 91b68c36-0ef8-4607-a4e9-4e3b43e21c02 ae374939-9d91-4449-9df8-37b91f6c4182

## 3. Inputs and Contracts
Input: Profile metadata for Export-CorePreferences.
Output: Script execution status.

## 4. Execute
- Write Export-CorePreferences in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Export-CorePreferences"` or `bash -c "Export-CorePreferences"` depending on the environment. Expected output: success for PreferencesExportCore(PS1).

## 7. Done When
- [ ] Criterion 1: Export-CorePreferences is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
