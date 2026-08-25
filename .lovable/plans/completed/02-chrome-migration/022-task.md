---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section22"
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
  tests: "unit test-22"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 022 — Preferences Merge (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for PreferencesMerge(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Merge allowlisted subset using jq -s '.[0] * .[1]'. 9c6e2b31-d386-4839-856f-238ca5bbe08d c72c3e74-f329-4486-a004-ee8cf56a344d 23c3455a-f3b5-4225-8a3a-be2e5b1f1271 e90d8b69-2ce8-46c7-9456-3c06ba0df682 c00111a5-25d5-4723-bdf5-08733491346a f8aae4c2-68e4-4d2b-b247-a5ca05dcdd0e d4e2d279-e878-4df1-9bbc-b6acd76017fd aad01e4c-f290-4e79-825e-6e45d6e913aa a6da1a81-d921-47d3-a7ff-0f217369e28e 7e34ff8f-2e03-4169-9423-e6f0b57078e8 32a7e6b6-16c3-4e5f-aff4-b4e9a41e3044 c5e136d1-b1e1-4ddc-9e8f-a2f5cbf8f593 ccd05348-fb98-4cac-8fc4-9dc66a14f6c5 1ec4f9be-7e28-4da5-bcfb-0190a5b9f50c 7b4b9431-e05a-4e8f-bac0-aea7d7ca6aee ed4cd045-81df-415b-80bf-7472ad26c8cd de2bbfa1-04c4-4fb5-8410-c266001e8dad aba84202-d913-4134-8dcb-006aacf0e328 6c12ec77-410d-4b6e-b295-0a7bbf0e621e 200fd35b-d0d3-46a1-8c61-56a4f4f26e55 e17097a5-a45e-42d3-a80e-e0183ea61c61 3dd446c3-0b3c-40b4-9ef0-4eaa83a81ee6 4f7eb33a-3f89-47f2-ac81-48e99e66aa83 3865b13d-4061-4ce7-8747-ec9537acb02a e2b54c74-3a51-45ed-964a-61991e489d09 b2157199-bac5-44c4-a613-28849addd874 0ea29929-f7bc-4d60-8669-8472535cbb03 f758f8db-631e-45cd-b8b2-9128e887ebd1 2f1b4064-46fb-4e4b-9d65-28835f8f40fa a8f3cde9-6425-458d-9e96-eb00a6fb25de a59da6c4-911d-4b12-b9e5-2670d8b9bb7d 2bceae9a-88f2-4948-aeb5-8037858f4e00 4e10b233-cf46-435c-9a03-5c132a161aae 8b18c985-ce9f-4c8a-989b-09d52d5f88fc 7c81cdd5-ff7f-499f-9fcf-c05e94a67074 309ea992-472d-43c5-82f6-b627fd552395 4c51401e-e217-46e8-aeda-700218d0fd5a c58a34c7-ba36-40d8-8304-08cb68457ec1 0a3c5059-d4b3-4831-98d4-4104c5acae6e b0aa557e-ed6c-4547-9546-0c89433931c9 a3025a67-a40c-45ac-ad16-0c12e9238d78 4dc4a56a-9b77-45d6-b7a7-04264aa09f5a c67d4cf6-8020-4c7c-8347-f71b3fc1d1d0 11c8e8d0-8020-4484-926d-cd26589d5f81 ba042a75-7ffe-41cf-abd5-668ef7475ec2 3fafac82-a5e9-451d-8f30-51be947125e9 6506d160-2c7d-428f-b75c-e93015d7cf43 79cc1b4a-e2d0-446a-8b9f-cf69c8818c03 644e964a-36fc-4cfe-93de-1cccecf3d07e a1781523-6e48-42ca-80db-1639c3675bbe 4cb9025a-c9b5-4251-8e21-380a2894f4e2 9dedd3c2-8869-49b1-8f89-42c1c85e1c0e f26d6d10-7c0c-4ce7-89e1-f670fcb35305 e04bbf9f-1f6d-4aab-b584-8112933b6ce8 9cc1a6d3-e918-42f1-8800-8ee172b7da47 1ec3d1d8-7cd3-4f99-8359-161350c0bb29 aaea97de-6207-41fc-b30e-9c8b36c77a44 8fdd6cbb-9c03-43bb-8d67-f8772faf7718 08257fdc-7783-4231-b75e-ec737368d701 44022f68-fcde-4a3c-8a45-8afcdce7b593 9572ceb8-aa95-4029-9ac7-b18da514b09f 08b9c43f-f034-4a4c-91ae-d55873fe2888 7c4eb527-7267-499d-b621-53b23d855425 e73a58a0-754c-43c3-bf97-2ee15a3cec1f 97d8b91e-09e3-4e56-8010-f1ef04661264 ba05f941-6046-4224-a261-9866051700e4 d4f76154-34c0-4c3a-846c-f34277d778d5 0bae592d-f70f-437b-a819-ba4bb26f14d5 c4404558-9dae-4638-b7f6-28a62ad23c6a 3fc6baaf-e867-4933-b1f4-9ac228e22d6e 41e9cb48-9b1f-4f32-b18d-a3843dcac6fb 18d7a128-044f-4b32-878b-5daed60be1cd 3d26d504-6c72-40ce-8ff7-d6c0239bb139 c7915ead-6a71-47b6-b893-e6706c1fa81e bf281973-6535-454b-96d0-cebb8727470a c455f7f2-5d88-4446-9b0a-f04e05df9487 93e34660-73ff-41e1-9645-11e469cc5f07 18a457d0-f27a-4671-bec1-ec8b497bb390 1771174b-b57e-4ac5-955c-daf0c0646ab4 56e980f0-f33a-44ad-815d-e38ab4259061 7156d624-bc14-4d99-b7b9-7a8080041043 f04f7760-0d66-48bb-b40a-6db31c612d3f ec89f635-842c-4eb7-9394-e23a63e33507 8901edac-1bfd-4f48-be1a-a21a9bd14c81 fc1225aa-2d11-4524-abc4-ed52419cdc67 f4f9399f-001c-4098-89db-865799ec83de 2de3b9ff-88a4-49d9-a3f2-8a5e0fbe5366 52ccb959-a63c-4cac-9841-d34a92700941 0b3b1be2-34d7-4337-9b1a-6cb24f87c3d3 28f2aa9f-2bb0-4ab8-9d59-38357d55a7b8 923d829e-cd97-4690-beca-d5180d5ed28c b64294b6-dea3-4374-8f3f-72bcc5e1b009 671b104d-4a63-4d79-a16d-f86baaced41f ec24d932-4def-4e97-89f9-54cfccb47f43 8e86a39d-2aec-423f-8678-2efa9fd057d4 89335dbf-889b-47f8-868b-e8891ecae1cd d3a9a644-b470-47f9-b1e4-5693201f0604 65a99eed-ce8d-4eea-8672-6cd0a8ae1d79 f633091d-7b7f-475a-b416-306b0b35ce79 b31c31d0-d806-46cf-87e3-49ae4756cf61 5a725716-65b4-4efa-b5ce-5a3efa669fe7 df0ddb46-73e7-42d6-aeda-dfc7e220ab2e 78e3bf86-4775-40e0-b78c-06326351c558 653e647c-d0b0-4b69-8396-7acfb9c4e4c0 d37534a6-a6b1-44e5-889b-358db5c66378 a3c8bba7-5dc5-4aab-9696-ff73b5f59253 93f38367-ca47-4e6d-ba3b-cc31248dabd2 d78b43c9-044f-4e17-9b37-eda1119765d1 8677e8b0-c90a-496d-a3cc-1a8c9383e962 30b9bfa5-59bc-4571-9a2f-13d6ac9bf4de 864a4466-c9b1-4ecc-b822-1c46eedf580d 82bebdac-4437-434c-9ef6-2123b1f59ef3 284d487c-6440-491f-9127-1b0867c75ce6 3c34cf7f-a05a-432f-87b9-28b2c8360de9 05e6e644-b5a2-465c-b7a8-24f88e12301a 407cde3d-908a-4935-9ac5-b5e4e3130b07 9f9c6602-9904-410c-bcd4-ea8fad0f53cd e6dc8d7b-e37d-40c8-914b-1db82a70a3b8 8fbc282f-b9c6-40c1-9b81-64a894579033 747e2926-f208-4d6b-95a5-5ca425ed308c 46f0fb30-0a4a-4476-a961-73d72c2225f0 2078d5e8-c392-4321-8dc5-c769ecc504cf f7dbaee6-ab7b-496b-b381-119b6663ca8e d0e9e5c5-6c5d-4cb1-9238-f82190f1d221 ed4acb3c-6685-465c-9dd1-ad58a2dea101 27bece6d-c062-4c11-b55d-330ea6dd96d1 bf660a30-a361-482e-8529-5ea0b20a833a b8d508f2-4edf-4579-a9ce-6b2aec66ff30 f21245db-13d6-4eca-9cd3-3021a87c47f1 403e75fe-34ba-4a8c-aca0-37bab29bf1b6 e1e8035c-f262-4205-a785-fdd1c3d2a49d b4194010-e913-43ff-8316-d2d995f0a2ae 5f8e5580-f88e-4b2f-961c-2c41f0a93be7 84245bb7-bc49-4c0f-a90c-0597392783eb 01b1a813-51a6-4c3c-9526-c3f1f525a4fb c4e6c472-a771-4152-8bae-f9764d551376 b7f04baa-e24a-48da-9ee3-19a2d2e146af 16427e8a-17dc-4dfb-bfa6-0607b72723da 6a48e1c2-88b5-47b9-bde1-b96971cccfb0 e840a9be-fff3-482e-be35-d65636665d5b 5e4596ca-2c94-4b6f-9225-f6aaaee5b795 1a2d85ef-b6f1-42de-9f7c-16417c64e8fa 04ad0dbe-ed64-4c78-9358-d0258b0ffdd4 f7938b80-cb30-4bc7-b224-c91d0bf49bac 1aee2f6d-b28d-483f-b67f-cb4a79224146 29903996-c211-44eb-b72e-f3329bda380f 5c468516-9559-4fd9-9ce8-469a0ff60f99 1a6edbf6-eec5-4fc6-8317-65ff2fa6467e 82ea5499-dcd8-4f3c-bffd-b94d62d27360 2bd19a2e-96d3-4691-a6b2-9a289e8d7277 2cb987c5-7eb3-44ae-8a5d-bcff4632da65 bb9a0961-93b8-44d0-834f-da49a9356189 7ad904a7-3054-4c14-a6f2-1078b5631189 c0df984f-8da0-4417-b558-e647119718a5 fc431bbc-12b7-468a-929a-c67dbe4d0885 ea0be418-ecb6-4102-857a-c73d60f837a8 6efbef20-778a-47eb-912b-c24a9489c33d 163980e6-219f-459f-ad97-f7d48eb550ff 36f366ec-385d-46ec-a2b4-021b5e7a712d 7d4b56ee-8f7f-4946-aadc-2a947fcbc8fd 70f98cf6-12ef-46f9-b8e5-3989485ad8fd 3a4b0f07-8a54-42c8-97d5-cb48dd5ce586 f763f888-9a74-4bb7-a228-ae8cf13b34cb ec39e263-cb9d-4940-a10f-63891ca85fb9 6976b78c-2c8b-4808-9083-f87a6e4414f6 c4d50b4c-d862-4fd7-930a-02480fbf87a5 e0a55977-4943-4bc8-a9b6-4d2d3878cbaa 4560f169-c4a9-47f7-b572-bd3afcc57b35 7e590069-fade-46de-a13e-0e32f79c101f 6ec97305-f79c-440b-878e-1a85d1a21fc0 41833b15-80c5-4c29-a41f-b7b4754cad34 16573c0a-b1f3-41a4-9d4c-a9d9043b9922 bedbc22c-98a3-4c90-b7f1-51c3a2c635c8 5c1102c8-716e-4f44-b5be-dae2dfecfcd5 5ba11c35-08f9-4d09-b0ec-a0d3270a2b55 c183af69-32cc-42d1-9733-1480456f5816 02c09ef1-8eaf-4ba4-9e9e-f1175e3d2dc0 b4ea8d19-6771-41cd-8e06-5ceebc0e1f7c 7bf81716-2a72-4102-8fd9-d0d8afea9a18 e6d578d8-9490-4ec7-b54e-c9dd6eb00009 72d63fe0-013d-400e-8df7-75d91eabc7bf b38afa52-3849-4555-a132-7c0c5b4002f4 ef55f0f1-d840-4921-939c-8c0de4e6669e f24f49df-b289-4eea-9c78-1f0406df1b51 9ebba0f9-bdd4-466b-b5d2-21395db2916a 0cf53dc9-e024-47ce-a120-7fc48675518e 2cfd4fb1-b92e-4145-94c1-38745eef7c49 d060fae5-a4cb-4615-83b2-4c2dbc3a2e41 ecbd98c9-f3ed-4a0c-9081-0fd78cc94cd8 bc02ef51-363c-4e03-9909-70f4dd27874a 00b86cd1-dbf0-467a-a35a-e1dd9f024891 c73feb82-f686-4011-8519-c2a89ea8d6f8 e91c2466-e645-4c71-9a30-53290ffe9205 d724660a-4a00-4c5d-8f53-8c642523e74e c9246a9d-de1a-4d24-a6b4-e371bab6f12e 0679e482-239b-4ebd-a48c-d6a3ceaa0b91 4226ecc9-12e5-4dec-bd28-c1480fa03592 03d381c6-4f4b-4b35-b501-bff1c8e357d7 7349d100-dc95-4da7-947e-96c643a2c582 751fafb9-ede9-4a6f-8571-113de8285905 fcd00b92-9e8b-4ed9-b25d-e2e7b2c95fb7 af894106-5ba2-446d-9df6-358770a712d3 d4557005-e91d-4142-8f21-248c7efedc4a ddaa14ff-4000-4ef2-9ce8-5dc982e51123 b70c1fc2-8c90-472d-bb28-0be3c5970cf6 fe6fc556-4840-41e5-8869-e38b290c7a75 4e5577c9-aff6-4a57-9441-3492918fb5ab fcd47757-2385-48bd-8401-35baba37fc6f cf47ad4e-b5f4-4828-a44d-101776338147 23039f28-4510-490e-a8ad-429d8648884d a7f14e8d-8356-4b59-8949-5113c1f4faa9 8d203bdd-70ec-47bf-a3a7-bd96d3ce79f7 9fd33346-5e6c-4800-8d28-ef30883231f4 a051e2a2-66db-4f91-a1fd-c46c30103de8 16598319-21f0-4404-8c18-a97885c8a31b 790285cb-c105-4330-8544-6e6a0ca4f19a 83a89814-ff69-4906-93e9-37363bb89e52 62a09799-94d9-4efc-ab62-632f54c8009e 846b28dd-0ceb-4e0a-8438-b666c6dc6d3c be548f04-4575-4a2a-a28c-6190251d2ba4 823c7636-2c34-4933-80c8-1e18e502cf78 71665d10-9c20-49e9-a141-46f3bc555a3b 60a624d6-6eca-4ab0-874a-13c26406b742 c917379a-77c2-4466-845b-d6a92325b962 41a5947f-8e57-4b9d-a3cb-a221de5949d0 5480825c-8cf3-4210-b51a-e28a79ce1dd8 ca2e6e8e-86b1-4546-9340-e676f9c76a59 5ef09e24-f973-4c56-b988-6e863a4fb1c1 0d1bd178-16f5-44dc-b9fd-6465ac77a6b9 7ca03e88-65b3-4ce4-8174-092afb04e76b 87c0070d-2f7e-473b-ae47-58ad9ebb369a b36d10de-373d-458b-b1f9-d85a068ab335 467ff2b2-8bed-4115-8722-75f605b5d953 c88c49d4-7377-4709-b35a-65f7f3f26fc2 09bdc3bd-4ae9-474e-b5d1-812369a12510 8aea12c4-dea9-4d44-9596-5fecdd9d0f1a 8359d1c5-af6f-4358-b7bb-3369399d93a5 88fcc753-84a4-42d3-9ed8-7c03e44638db 4a07ad93-db57-4ce7-a05a-4a7910ee8b10 8d5b21b1-e769-4449-8680-91ef06762fa2 63fecf8f-2a97-4a8a-a334-578f7a0b4d15 6a7c4021-5b91-48d0-9cdd-12f0e8dab1c1 e5279bdc-2ab4-42a4-9d3d-bdf5de9e7dfd d99c5151-194c-4ef4-a571-b436102491a1 dfd22a1a-32e1-469c-ab29-aa3b5b3acfa1 dbc17409-5c54-4716-91d8-311653d94c8e 840a8117-2049-4965-bf20-13ae845b7cb7 a8c4f6c3-8f41-46ac-acd5-499ec54bb603 7e78fc81-0987-430e-aa91-e8718afd7c88 d0fd7591-5186-4392-9250-9fa41909e1be

## 3. Inputs and Contracts
Input: Profile metadata for import_preferences().
Output: Script execution status.

## 4. Execute
- Write import_preferences() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "import_preferences()"` or `bash -c "import_preferences()"` depending on the environment. Expected output: success for PreferencesMerge(SH).

## 7. Done When
- [ ] Criterion 1: import_preferences() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
