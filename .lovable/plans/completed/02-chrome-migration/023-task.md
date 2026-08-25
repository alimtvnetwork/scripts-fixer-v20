---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [scripts/import-chrome-profile.sh]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section23"
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
  tests: "unit test-23"
  ci_cd_guard: "linter-scripts/check-bash.sh"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task 023 — Preferences Rewrite (SH)

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for PreferencesRewrite(SH).
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
Rewrite download.default_directory to HOME/Downloads. 4d4cd3d2-cea0-499b-a8c2-c7aa743f97be b404f323-94c1-41da-abc0-09368aecfbc9 a0c3803b-d6ee-47f5-b233-2dd23b0c3fa9 fed80870-d270-4ec0-ae3d-d831dcb08ceb b7faac13-a3c6-4720-a750-e34a0a555e08 76b3d84b-d106-48de-ac82-80c2c7783cc3 d26ea01c-076e-4005-8ec7-068a683a36ab d93a16eb-80cf-4b30-9bbf-87a0ea862cdf e682ba4b-cc0f-4755-b221-b1de96947bc4 67723609-8819-4e8a-8817-e738051b5434 2041bfd2-da25-42d9-9314-3de37c5b8c6f 84eb7132-2a20-4560-9dda-8f7b1a573d84 d7ba9dd6-3080-4456-a600-c3ffb001d265 43ba7b01-3c98-4149-8b27-d78afe091668 98acfd0d-531d-42bb-b404-87f12fd220ad 31f82580-fd8f-4562-9ab4-917e950bc88e da2c05c5-2a57-4284-9eb0-4cbdec13a4e4 51802c16-7d86-4fa1-b34e-bce84d50a8e3 9a2feff7-40a6-4260-9d75-03e6105cad1c 9e47836d-65a3-4cd9-98bf-73771c26a92b fba293dc-000f-4e23-9bac-22fcd7cb4c67 8e206bec-1784-492d-96cb-6ce7aae86460 11ac10cb-565e-4701-acba-b0cadc65df2b 152b25d0-478b-48b0-9823-409386982dd1 484a429b-2212-4d49-a935-7a8f4d1ad538 b8bb87e1-7d94-43e0-b0f3-71856b04758d e6ab483a-ee60-4b8e-b42c-fdd1cfe14237 37ad1389-0f32-45a3-b251-a08f1c7b7ae8 60889270-21bb-43b2-87ba-5c5a450cf335 a10e1b51-21e5-460a-ab1f-72cbfd8abb57 f3f030a3-09f0-495f-9475-84f3e76dd1ed a9b6f290-f387-4b98-8d4b-644a6fa4ff17 5646e57a-44ef-4d52-a443-7f5ea51567d0 345fd87a-ecbc-4a4b-b22d-f3d007066920 a51abdbb-6a31-4374-95dc-fcf2141a080c 41a920e0-607b-4d5e-92ed-f49d9edbc179 19473714-52f6-4777-b6e1-64da0955d246 87379009-4e20-4101-bd89-cc22693b0a85 96fc2fd4-a595-4c85-b7df-219af1758764 2e08b697-5b10-42e0-97cb-44c5910c0c19 582f73f2-e612-4ef8-b043-1ac48ecaf1d5 6e5b14e4-775a-4312-ac2f-4517a80ebc02 8f40a307-0e48-4d1d-9951-5bf3f8bf1333 9330c98e-e4f0-460d-81e2-b6400180d578 8f711545-2bc1-49db-80ec-4455cb2dbebe 051b1314-d48a-46af-b8e0-53613a21625e b8da3e25-abae-421c-a1d6-afaeb4376432 e618d19e-eb59-4bb0-b5f3-3e2016184db5 433f9383-69ca-4890-9b29-50f4299440a4 fb13e456-a757-449b-9c0d-39c00871a266 71106e09-ad08-4586-bfcc-bd946ba1b5f8 8dcf45b8-96b4-4c3c-a36a-150e01f097ce cc5f19b4-734c-4a5e-bfe5-0dbace805e26 bd561ab6-1663-4380-8c5f-ec92a9429c5e dab5fb7a-2d40-4739-a019-2265e07ffc20 7543a81c-3703-45fb-8bca-87954af16910 5b6b5d20-808f-484a-8344-cdee6b6c22eb 1d154527-b43a-4325-b3c7-405153e3b1f5 25e7e19b-7694-4651-ab5f-a648d4ceadf7 5ff0e51d-7432-4473-811d-ba52673e7321 c9de5cdd-5c85-49d9-a85c-58de9087773e c5e7c73f-1a3d-4479-82b4-4cb0915a74df 8b9697d4-73f1-48ef-ba77-52a01eb7ea0e 007882b1-3f25-4387-a6a8-a795ef242217 73d45d80-1425-4867-b5ae-b5885393c589 5bec6368-9910-49d4-81c2-6d6092d2d856 91035fce-9f94-40d6-87f1-ccb03ce00cbe 8eebabfa-e47a-444b-89cd-9d6613ee47c7 65e680d4-50a1-42fc-a74c-269b39e45912 e98fcaae-2234-4a11-af6b-dd92cf3dabc2 b8605cd8-6147-45df-b813-0994737d4325 090d61ed-2f1a-4084-9a69-7e0a6caec151 c8d75e14-0157-4680-b9ae-0a29ec993262 59c26b1b-6948-4dd6-8b14-0b919fb8eab1 f2c5a28e-041e-47b6-94ea-db5bed562df7 cc8a5b2e-155f-4655-890b-b8bc54bd0723 e2b6789b-5109-4141-9898-d74c88926393 729e4b5e-3ecb-4c6f-8bd8-12edd42e72c6 cbcec56d-22bf-4ba7-97de-5ba14c47b24b 53e3a59d-240c-4163-b130-4e4b1603c1aa d18c856c-60e5-420f-ab47-778466b060c8 12db5011-5bca-4519-8239-01dbc70877dc f51fdb97-678a-4687-9706-672ae0684739 a9f401a4-742c-48f3-b151-7bf44b30b9ba d712a164-1778-4fde-9cde-843fd0eea1a3 e0edd938-ac21-4d6c-bd76-05467bccde0c 7035e6e0-9ff1-43c9-8cb0-47fcc5e36f5b ad0ecfea-2649-43cf-a81a-f8c075e695a8 7329724d-4988-46f3-8eec-5973b175c23d 8215172c-f277-404e-83d4-210d787ad376 281e9a7c-7a32-4685-9ea4-374dea362fd8 caff6e90-a388-4420-947a-c23bcfe4aea1 6c521649-f4a0-470d-9ebf-e60151d473d3 600a8d03-fd47-4ff9-9de7-562fb720b2fa 1c597c88-f263-49d0-bbe9-54012773090b ea4497d2-b6db-4711-8a56-462fb56521e9 2a39174e-1162-40ff-8034-a6236812a71c 9bcc2133-cfe9-41f1-9b73-edea6aaa119f 8ac8667c-2bdc-4846-9146-2e909824029c b15e6fb6-5250-4413-b5b8-c09fe4b9359b eea1c966-9da5-49c5-861e-9881f91ce69a 54c60c8c-97c5-477b-9da1-9f5b2bdf11e9 91d3ae86-9423-4952-9456-fc83469dbc81 b2d17e2d-f0a3-440a-9c2a-660f7b36bae9 137f6b89-1fe3-42bd-ad6f-0a55fd8e96ed 52744c02-9917-4c40-95f2-f77e2c79eb45 7674d116-b2f0-4a21-bdfe-f4d6ac5ba74a ff517a22-39cc-4ff6-bc7d-3073166fad58 7eea3b38-71a1-4284-b4f3-29d57f5571d6 36b5ca50-a828-4f6c-bdc2-17e7d05102ab 9b660f92-2e2a-4d47-8c86-9ab05bad2a0f df05f6e4-c9c3-4776-8179-241ca3dee9a5 d33ae4c3-ec8a-41b9-bdd3-941107671957 0943e87d-2a6c-4560-9d2a-92aba62c5951 3c2cc06c-b4f2-4909-8e32-869d856f5c92 9d9a1f2a-29b5-4aac-8177-abfbf8ffeaa7 52f1b4ed-f86c-4bf7-8620-184a0314bcb5 cd0e560d-9fc3-4733-bc37-820518cf304f fb749c2a-71ed-471b-8fb5-c380cd0bdff5 3526b9f0-d6d2-4b34-959d-116065b30b75 b2b02584-4d88-4464-bb72-7f3c067cceae 12f6b6ae-84ef-4288-817a-a40b77e52a48 52ee8d20-aee2-4f37-b292-4c547cc0255f 6277bca3-3b62-443d-9b67-6bb10ee325b8 36f4c868-1e3f-47e8-97a4-ea230ea72e12 56449817-d526-48b3-a55c-05fdf6e4a08d 3c8e5274-dc72-4475-82be-6d0a40fe59cb 5a47b18b-d393-472b-88d0-e85ab6147711 680cd759-32b5-4983-852c-d72b1ef2cc6d 4429bd58-c363-4fba-ac05-83cde1c1a22f 1bf0d5ed-7124-48eb-bae5-d24e33a3da00 75ed04ec-0d04-4e70-8397-c36e95565423 e105053d-c87e-4406-8646-cda55a42335f a754fa4c-1294-42fc-a1ed-05fda6f6f896 1173d962-574f-4a7f-a12e-9e63dc739336 658471d4-1a2b-4fe8-9698-4bffd1d7b831 65a7a6f1-a48c-4a07-95dd-44bf08a17bc1 47609f19-1afb-46b3-96fb-207922718503 9dcaca21-4ffe-43e1-80e8-a0dbb369859f 752ef024-05c5-4143-b4de-5fbff5630c15 c0f4861c-c0bf-4b6a-a9bc-994e6ccba498 fce72d14-68e9-47a7-8fcc-638ea77a8287 051c3b70-f221-46c5-aa97-9f1db5d03a2c f1823b9e-c56e-493a-8875-a37ba4063bba b1990092-3b33-4d19-86b0-2c593d6424e4 31647ba4-cf23-4068-889f-db471f0e93f9 7799bf5a-9ec5-4792-b2c1-8e58a998e63e aa454912-fb5d-4fdf-903d-432a4a719321 6ce4b10a-4c9e-49f2-9812-35daeb077588 ad16b9d3-1320-462b-84c8-12cc2dbea43b e9d9e8df-790c-4967-b3c9-25ea57128723 edb1f5c2-19bc-476b-9ffd-2ee421506983 ae23f352-eda0-422a-b528-42b823c001ce 4419b0f6-eb25-4867-980c-62bb9e96086f 22a0ed47-e7cd-46cf-86da-9dd29e1cdc7f da5587fe-147b-486b-b6aa-c428e87b26c8 bca384d0-2b4b-4523-8bb2-2141e4e53e87 1368fb2c-e0bc-4d95-864a-e59215cd680d a24360a2-ec16-4797-9939-76ea563fe221 f43af5c8-e627-4a4c-8178-11f9ece53203 307403e6-9cd2-43a9-ae80-96d5752f27e6 26fe41b7-6a5e-4e87-b56e-232dbd111fd2 9d6b7e16-e23d-4fb7-b0fd-fdd1c1ec35d7 567fe430-f210-49b6-9a5e-d6f37adce004 2b15c908-19bb-43af-a4ea-37be6584f1e3 1182cad6-f56f-4e16-8037-e76c138cc18c 52b06e0a-c430-490e-b62f-c0d3097d944e 6beebf7f-9252-4ea5-857d-dc573a46ed0f 6b944427-4288-49bd-b12f-fdd84782a950 695745e0-ea23-4bf0-82f5-9d41a31fc162 3f3763b9-79c0-4b8a-8fa2-420eb8a7d791 df85905c-bad6-4fe5-967c-fc901d9690ba 19618c4c-c6ee-4324-976d-1db4ca3d8105 f0e58a6d-366e-4ffe-8911-e7a9ad4a4122 dcebc348-c180-415c-9a44-bf405caeb571 df16737e-bad4-4ab8-a2f5-d3df198a7d0f e93235fa-2d7c-4fca-a428-def1e858a195 e6b9a88c-193b-4764-9f42-ff4990067023 07155c3b-1c42-4b30-aede-167513eac393 a826889a-5b6f-4dae-b27d-690085a6775a 21cf2a5c-787a-4268-ad3b-e380ac81d839 b4d1e6fd-f410-4018-8600-8dab1c61b05a bec33e16-c8cd-42ba-9549-c33deff0622c 7ffb1f2a-8eff-40e9-8634-7d17d67328ad fc00d4f4-6ad6-43d4-83f6-5e227f69d815 7a3134db-713e-428f-990d-237790c545c9 e1ceb2a8-ad14-40b8-92c3-7fe97f49b2da 52cb6040-1c1b-4ceb-b379-4a44cc5a20fb 3b7d0aed-2964-43b3-b820-d9c8b3abe0f6 6942463e-4305-4000-983d-9a75587fce18 0eef3a75-f9b6-4d25-8726-b89fd40da2c5 b5ca169e-a1fb-4b5c-b47a-a35b9fa3a3a7 db65e603-808a-468d-afc9-0ab52a1c25e4 213eafd2-64fd-428d-afb3-9beb25b2bc01 bbe3b1c1-2303-411e-8414-93f57cfca867 1a3ffc69-bf14-451c-9178-f0040f1bc979 4d01268b-9d8a-4333-b95f-23046792eade e8893b76-1344-4801-8965-6904b124ef6f f1bf9879-05c1-4cb9-b034-7a6e1abcc091 a771ea28-838a-4ca2-af7a-2edb84a1f6d9 a3b5a98f-c814-4041-b4df-b195e41bb956 e37e4109-d2fc-4d68-8b8f-69500d725efa 726c2d50-8d31-4be6-8119-e949ce3b4b9d ddb7a048-a247-4b6b-a646-c1bef50b6b21 7d528c60-37e4-4f84-8f94-86f96e87f5d9 40149402-8fb3-4511-9a6a-e6a8e74df21a 6da55335-2d69-42bc-ab9d-81a1c41844e8 6fa7bbef-f7a8-43e8-8e95-28d87d014a84 e8b09eee-1391-4988-80c1-5e53651083b8 f9f89d1c-f6b7-49f3-914c-864d0efd18a4 8c5de7cc-53bb-4e2e-b149-ef14ecbfe83d 0d3a233e-aef3-4758-ad1e-4b58be90b297 2691cc32-b60b-4f83-ac55-9a8e36dbf143 5885746e-7142-401d-89a3-41ba900f64e7 209773ed-7a73-4345-9790-c1ba4af2d011 0015570d-2e05-4f2d-b991-104d4cd482c4 9eaaf2da-01d7-4f8d-a311-a9610ca7ca47 1164d19b-a409-44fc-9844-8891ac4d3d55 9b190d80-5fe5-492e-a4e2-9f1a127647f5 8dabfdf6-9dea-48f8-ad15-39ae69a1dbbf d0fd9fd0-cddd-49ce-9e95-8043a78ca3bb cbdc618a-d129-4ee6-b556-f52759d0436b 504b2035-7415-46ef-849b-3411b11a4bfd e000c9b4-3169-4101-80bf-ffefab5606d5 814c23ba-a9de-435d-b609-e08b8135e29e a4fc03ef-b2d4-4a6f-aa89-ca0c0ca85c51 37e8e800-f6fe-4354-af9a-60db36285404 90cfaed2-9610-458d-a8d2-87125853dd82 1e3a18eb-2c4c-446a-bbda-705af30f1bc9 75454dc4-364d-4163-864a-6289a9be0f36 149c3007-05d4-4b9a-8b5a-75e44776d39d c5441a1d-dd42-49f0-a0d8-38dbf13391e3 eb8f7b2b-cc9d-4fff-a779-df8037b0b5f4 b6a6cb26-31ec-4add-b032-d116ab1b97e8 13bb2808-06df-455f-9ce2-af4f4b1a77c3 d5aa042c-22e2-4175-980b-e4194e430443 40c78aa0-079a-4018-9477-e76b1948d6a7 b2e1ae30-c84a-47fd-a4a0-7c6f0b64b6ef b66a5ee7-18b0-4a77-924b-fb49565bcede 8977fee7-12aa-4b18-973c-6fd4a454cee4 5b61b6ce-4c3d-4d09-9eeb-218adbdf07f9 1f1bff92-a03b-4290-8e62-76169e16bb3c a7b2b927-2049-45ec-8700-578c7051f50b a1d291f2-8198-45b0-90ff-0af9a441bc0b c729a25e-5d91-40cb-8ff9-0fdcce6f4ec8 8920aa58-fef2-4644-9330-870dd5f6f4e5 565b8403-5f1a-4d98-b258-7dc5fed26a6b 88d04284-9617-48b7-812d-70447be7f02e 72766359-a413-4fbc-a4c6-4af88f93bf00 0c93ce43-0d44-4710-99cb-8ded8a64a28a

## 3. Inputs and Contracts
Input: Profile metadata for rewrite_pref_paths().
Output: Script execution status.

## 4. Execute
- Write rewrite_pref_paths() in import-chrome-profile.sh.

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run `pwsh -c "rewrite_pref_paths()"` or `bash -c "rewrite_pref_paths()"` depending on the environment. Expected output: success for PreferencesRewrite(SH).

## 7. Done When
- [ ] Criterion 1: rewrite_pref_paths() is implemented.
- [ ] Criterion 2: Linter passes for file scripts/import-chrome-profile.sh.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
