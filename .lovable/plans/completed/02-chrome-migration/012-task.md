---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/export-chrome-profile.ps1]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section12"
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
  tests: "unit test-12"
  ci_cd_guard: "linter-scripts/check-powershell.ps1"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 012 — Autofill Export (PS1)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for AutofillExport(PS1).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Query autofill_profiles for non-card addresses. 44d58ea3-efc7-4419-a1d9-f175eab73a3a b79c7a84-df35-4ecd-a1d2-a664b05c25a6 f7b378af-097a-4846-974f-9c528ebaa5b8 1de917ac-1bd9-46e8-8e17-60009e1dac97 ae643f05-1ee8-4233-8341-92fec8475fa2 2c834b67-b5a9-4bdd-8324-bb281ecf2d2e 23895056-e5a8-47ce-bcce-5add81c535fc 46dd2ab2-43ae-4a8d-808c-32dd946968e3 9d9a18b7-d8f4-4672-9160-608e313fc704 71b2d8b0-6595-4452-b72e-4cc3aa56d571 3a3b855f-a392-476c-a722-e29f660020b5 b25cff61-f156-48c0-91f7-fcadf67cfc10 b80c1490-73bb-49e2-8ce9-239cfb979fed cecc4c8b-3185-4f35-b075-1c750d722146 3bb20063-1b51-4d74-bfa4-47d7f1b8beb1 61f6a2ab-04ec-4e56-89f6-795ba509036f 3093ca29-3a58-449f-8e4f-aaeeff989447 64504159-6b91-49f4-92ca-97dda25fcd5e 8389bdb3-c97f-4fc9-a76d-703cc92eec4b 6145aebb-f4d5-4e10-8566-ab6453583d78 01880a7c-bbaa-473a-a3c7-ca23120406cc b3647519-f11f-4d4a-b07d-18d7f3b171ea 6d5bedfc-f75b-4688-beea-810dbd40fc8e 78b17dd2-b575-4baf-95e2-32082c572246 b17bd91b-412b-48fd-8024-388760faefcf cad20a56-3428-4163-a285-e64c13db3ea4 288960e2-ef6b-49c3-8ee1-9a968fe7cf1a 020292bd-428f-4853-9bc9-e15b5d7626ca b71e789c-9609-404e-9624-a6b2b8e04c1f f1e061e8-4843-4893-9938-95ac1e98d406 00010258-8075-428c-a737-e44848af33de 2e9e5179-616b-4b29-bdd4-d93d0571c519 b8f0f143-6957-4631-9fd8-5644e81dfba2 03321ecb-40eb-4871-89aa-02cba2d36c1c 48a601e6-ffd2-48c4-a9d2-730b8fb804b9 5f0a94f0-3b20-4dbd-a788-7426017735c3 9b5e549e-81e3-467e-9d78-9e6e4494df7f 38870dcb-d8cd-4fa6-a132-fcbf7be2c997 16d6644d-2149-474c-ad9c-d03f32086ad3 5de6c5ae-0936-4b7f-8bb1-9b45769338d7 7e9e2282-1aad-4320-abe5-fcecd606c93f 7ed18b75-63ba-4cf4-a014-29906a9bcc78 cdd8ffb4-cbd4-479c-bd7d-d1df50076e5a 5132868b-1239-4aba-8b1d-d3e493f9388d 5a9179fc-566b-46f9-a30b-8a0fd7c69e9b 508bd534-8871-40d6-bf34-b756c7bb605e ae3eeee2-0dcc-4dd9-8ffd-686ec0bdf534 33bdf77c-9709-4f8e-839c-846b070513b4 2d0e543c-d683-472f-8b2b-7b25a3d8b6d7 348260cb-7dc2-49d9-abdb-f22afb5e7e7f 623fd481-d13a-46bf-860a-0f3524eda376 034097c4-f281-4ae4-b3fd-9fcda033f934 3ed058fd-1e6c-4adb-9a1f-9f1cd94a5eb9 1045b31a-137e-4a69-9db9-0f5ec8b124a0 7f2fedbe-6d8d-4870-872c-1d765ebac1e6 2a33b4fa-ddb7-4c32-8801-3db6a3ddb9ab ddefad40-0208-4487-8bc1-7fcd7ec5846f f7194d72-b0f1-43bf-b57c-4049131ece8b cec2151b-47c2-463d-9fac-6b2f5837b06f 6802773f-06b6-4454-b29d-5fa21bbdbb30 0861fa3d-4706-49e9-a743-1c20cbf37ff4 c2fac096-6cbd-4f54-8bf6-bdeadb85105f 3cf4f0d7-c956-4cf8-9ca0-1a45e3a4ddde 2971d03e-7a38-4569-bc8c-d8a4c44872ae 4330f7b1-ef08-43f2-8400-c907d5309bea a3662039-2abf-4870-9ac2-3218acc7e7ea 351eb8b7-7907-4df2-b2f9-7e108113d224 e7607660-1912-40ed-83d5-0d739585cd43 1934d511-3525-461f-992e-747b96bd024c f982882a-cb06-4017-8ffd-5afa0510e5f2 7d8ed553-0029-4f36-ae3f-65a6cfdce855 4d3a57f4-2d36-4764-9ca4-2d52ae427579 5860d076-be1c-4059-87fa-e4b557d20414 2e9abeca-982a-4a03-9c49-24982247e079 084cd012-02a6-45bf-8ce3-6a75e369ab87 7d001106-0f6f-449a-a28d-d1752f875a82 c31baec1-d570-4178-9347-8f98ab9f16fc b7b171b3-4f49-4523-87c6-22d17a66c262 d3a61cfc-e0ce-4b19-8e52-1cd09039f5e6 d68a193f-7fb6-440b-b849-1049f819d357 88ff44fc-6d89-43f1-99cd-f3df70099b92 f4e50691-642d-4ccd-9ff6-a039bbdf40a1 762facc0-7572-434e-b211-2437e1b00469 f88624a5-5081-4a36-8a27-b25ad6f24320 30644693-5df3-4a84-ab89-f5fe3977ff4b 7bc7cf12-04f0-4ec8-aec5-2171eaf59fa9 da2e53d2-cdcd-4cd7-9a9e-c77227a73bfd 06c6dbab-25d1-4a95-a35f-496468e75e7b c74f2973-a23e-40b3-949e-b0674d83ba98 9be6307e-2f54-4536-a1ce-28a4e3237287 6f8af209-176e-45ac-a0bc-cce551845f10 b8fd0c96-4982-44b8-ac34-af81491b54e8 a20fb32f-3448-46e8-b0b4-7a66fd56e2a1 d6a76762-ea16-48a4-b4f7-6a222d984594 7d3f0232-c6f8-4058-8175-ba8e782a4696 e29df055-6cba-45c8-8501-bd167d605461 9b628017-b579-4417-b157-5a7ed7ae1952 5e8ea5a6-418f-455b-8c5d-7ecbc2f238f8 1af916e6-c580-4596-8c94-f710a645ea11 de304060-0fab-4931-b3e8-4a7b402991cf 3b65bdd0-5724-4460-a683-6b728aebc9b6 c60383cf-f234-4a70-abc4-1d98493682cf e8255708-38cb-4a84-accf-0c9afbecbd01 f62f98ca-8a33-407a-811d-35efc1674b93 b4b960fd-4347-4b4f-9473-f2ce4edcc940 bf2d309a-4d1f-4920-b8cd-6a77a55be1c1 9a644798-cf9e-4aa8-ae7a-d1e01a6754c2 1ead57c9-338e-434b-8063-4b7af5709618 86ea8bfd-4ec8-4350-927f-7973187b5a42 e4380236-b312-4dad-bb1a-0067fd5a0d8c cec9750b-9f2e-4489-9e02-2f2a5d72549f 1ec596af-5c9c-4753-938a-1f56d28d8cfe 86da11c8-0748-4256-867b-d4b81e478f3e 4e527081-fe63-430c-a9f9-b6100655e51f 33578db5-fbea-42c0-ac4b-e4f81610d2a5 e0f02fbe-66ba-4123-a4b4-f590d4858319 fe299c2f-1641-4ba1-99bb-53e73dce81c0 ab11d455-fa8e-4b1b-95b4-b71d5d81a8ba 9565feb0-5808-4308-9eff-b2eb451bc242 d8860e58-7bf4-4301-9d64-87b1f1c7b398 99bb1186-5d1d-43b4-b09d-0ed330746968 418f01fc-ee45-4b4d-9596-dd33fcdbf2e8 574e2945-27ff-4908-a00a-794b67dee1f1 4759d097-62a3-4e5d-9396-8563c8cecfd3 ca4b615b-7e40-414f-b043-0ed6e352191c 1d12167d-1c2f-4f04-a9bd-6fcb333a4fad 28e7e3d4-d58a-4120-b36d-f6898cc60e7a 53ae2e32-dcbd-43dd-8f3a-2ae081370ced 7fae67ec-7503-4a46-8534-7fedf9c433be 3cb67f32-e8a2-49a6-85dd-336bfa9c7f0d 92b765e1-bba7-48f5-a963-bdd1f8729783 5fb8be6a-680e-460d-b93f-b3545dfe24e8 c7fea5af-9c7b-4685-8526-92783286263c baab4984-bda2-4ba5-a333-68b1c2e36d1a be4d0664-ba29-4196-91b8-dcedfe5b2bf1 eef97337-0d6d-4234-8f5d-c58dc67352b9 c32c7e24-d69e-450a-81fc-9deda794e1ab f79b1dbb-62f9-489b-a4d5-07a45f5d635f 006e553f-c37b-4904-8931-7f81b83cc852 3f7d6a2d-f73e-4dba-8535-96e266981f3f dff47fdf-7473-48db-8764-bb1dbf058914 7dc50a6c-dc70-4915-bd2c-9412c2f2f6d7 77323f9f-440d-4a85-baf4-b5e443130e5e 6221f383-bf1c-46db-8665-701ff0fa2186 44e812d4-6939-471f-9031-52fcf8a93153 c0f5818f-f996-424c-8224-a9db889b4647 23dfc6aa-c774-4528-9ff1-02e2ab385c08 c9d397e6-d2ad-481e-81d3-6c70942c2a7b 773efa60-2c7d-4965-9a0e-058ca901cc97 9e395d6e-3713-4787-a70a-f5f813ce04c9 a6fb0917-6f91-409b-b96c-b0ad223146fe 6d5aac60-0431-4a6c-bd5d-46659e8880e4 99ce020e-2584-4794-8219-0e079ceccf3f 96c77223-cb53-410c-bbd0-e697a5816083 54950d68-8c75-4116-9116-ac29cf84d98e 03277468-abba-40c4-adc7-d40a6d18fb25 169384d4-5585-4b8a-b30b-c79ac90eb8c4 57a88e9b-3f00-4269-b53e-a6d709b58b64 523025d0-3cad-45a1-acc1-28ed5ecb13c7 1164a218-0d67-4ced-ae7c-dcd946ea8fc4 70842455-2b75-40ab-94ee-f1ce1d49ff90 4637de95-78ca-4ba0-9872-63603ee1f802 d51e658c-cd46-48f9-8bf7-7b5c7da762d2 b59e3ade-07cc-4a21-8a01-02409b6256dd e14cdeaf-84f4-44ea-b4e8-03d5e9966f92 af75eadd-bedc-4a72-8ff7-a9380bb2149a 09e76d74-7d3a-4d24-9601-37595b6c3a6f 735a1aaa-c025-451e-a0ec-24f5191315e6 44b619d0-06af-40c2-88fe-7b5413ac6a78 5ae3ee89-b560-4378-b8f9-2761e576937d 54a89cb2-3b6e-4d7c-acbe-6a9106b4b8ff c1e55d81-fda2-402c-a9f8-7ea1e68b41a1 92a3de11-d90d-4a59-9d3d-f578f0d017aa 46ac9577-2629-4d55-bf2f-2ca36da802f6 11c082cb-f09c-458d-8422-144e64490dfa 4634197e-e19f-4d90-9adc-5acd64d5f9ef 234810e3-df27-4cc6-bee0-27a9d92e5715 10779103-ec4e-41fc-a90d-8c3a08506d43 8bcec7bd-e9e1-4255-8fd6-683a43396f87 309d7ef6-5938-46fb-9f48-3f1e6b6c999a 69046b47-bea2-498c-9dd6-73799110a4ae 11b4b0cc-41a3-44bc-8ffd-783c198c1b34 85aa7dfe-86b8-4f70-9715-9d846b998730 b78246fd-0a75-409c-95c2-b2d340fb524a dc623d79-7753-41e5-848e-875630e84ce8 5a364fb1-0346-4345-aa97-de18f5921f3b c0dcf3e6-b148-42a2-8fa8-bf5884efdf11 5508afa7-840e-4d5c-a64b-25356d9b2fe9 d3fb3f20-24f2-4260-bcd8-6b9e664a1909 2cfd38cc-0097-49f6-8c98-9d47ea4697ee fa0524c6-d62b-448e-9369-dec02bea74b6 18fea7b0-006a-4c8c-85f6-c0cf6ec0e15d 504c870a-5431-4f2b-990a-46d03372d945 9e77838c-1177-40ec-87aa-13b6bbb638ff d024fcf9-c962-4863-ac03-224d8a860172 f82b77be-e943-4407-8352-ccf6d3a05494 07f57478-30ae-4335-a7d6-313ec40a68c8 f75c049d-3151-4041-8216-2cd031e7fdf5 df58f9bd-f5e1-4693-b99a-ebb4edfc2a11 c79243d1-b36b-45fb-aaaa-ce56c7e8e5a8 ffbf3b4b-c41b-4564-9cd7-2d7e30239d0b efb34b8d-4b54-43aa-a03a-6759c0f4a971 6ea6acbb-0dc6-4bca-afde-82025087c9b8 df93f2c9-cb16-48fe-b065-4ba9cf6230c1 5ba164a0-adba-40e9-8d8f-f3c2b4d1382d a676d233-bb02-4231-8630-628623af9fca 270bf22b-c862-4a75-96da-e3fd04053283 5f621270-8dda-4a87-95bd-5b15a8d2ee13 ada5d631-151f-4b44-b951-23143b934384 f4e12c9d-8bd1-495d-aae8-e66bd9fe28df 6d32160e-2f95-4c2e-8009-c28a89898236 5124adf2-a316-4842-8535-51818c0ff7dc 56f92673-5717-44c9-96f5-0c20552ba303 2a6676b4-c9db-49ba-8f53-a8758e00a246 fe164ee7-7f13-4483-8fcf-b1de71ab4d82 bfef0ce4-6044-44a1-8b4d-dc6a8123891b be17aa9e-9202-4ab6-b516-9971f647e261 8d495df9-53b8-4985-a578-6fe6e1db4d44 a9d183ad-e50b-4b47-806a-d10bac13eb24 9e0e900b-692f-4d23-9686-f185a81a66e9 70d0504c-7234-44c0-b39d-8cd4d1675546 c013f726-ce62-4b68-9d94-d0cec4811a31 b410e9fd-af04-4887-9c94-9c52af75c2a9 e3d01d30-8da6-4ad8-8747-d9f08572c385 340b136e-f8fa-4f75-a548-6f67d5ebb837 063592a7-0659-456e-9efd-96d9a582d698 97fe6389-e8a2-4c05-aaea-e0438670cf94 a528977f-1604-4e73-950a-d4b31549d806 16072900-1816-466c-b8bc-876b1bc1d1c8 2d0afcff-fa48-4d9a-8007-436ba14c56b4 0d1e41a2-65e8-4a1c-9e5a-f5349a346943 fc2b0677-620f-4fa9-a625-72e4d2c86a0e 1766aaf2-15db-4d83-8d93-a591d5630c24 9464267c-8960-476b-becc-b12c0f17cf9f e546b329-a869-4409-af9d-326d982a642d 584bd9f4-4b05-4efd-b3df-495e99fb8cd4 15b03396-f69a-44e1-88f0-dd930fad5021 28044553-254a-42ec-bcb3-1300788fdc68 02795406-5cc7-4d29-946a-3800d518eab3 d42359d2-2675-405f-9479-a3028223d530 b9e9dc2a-ea0b-40f2-ac53-c2041536fbfd 1aeff26e-1c9c-4b13-9070-6a3932326110 3b0b8d75-aaf0-4b2e-8c9e-9c2f85b4a518 801b8d10-bba7-4708-95fb-3c58a85fe9dc af0de5c3-e0ce-4672-a285-4dc2963042ec 19c4c15d-bf6e-4a21-8e74-983b52f37ca1 db8ffab0-fe78-4967-b6a2-2e5638ac4818 6d96794b-ade6-4d5a-81aa-9d0c7e01f0f4 8a674c9b-0050-47da-a96b-ad05887cb770 c17090d3-cd0f-4830-a4aa-913fc242c04e

## 3. Inputs and Contracts
Input: Profile metadata for Export-Autofill.
Output: Script execution status.

## 4. Execute
- Write Export-Autofill in export-chrome-profile.ps1.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "Export-Autofill"` or `bash -c "Export-Autofill"` depending on the environment. Expected output: success for AutofillExport(PS1).

## 7. Done When
- [ ] Criterion 1: Export-Autofill is implemented.
- [ ] Criterion 2: Linter passes for file scripts/export-chrome-profile.ps1.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
