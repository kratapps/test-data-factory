# Release Notes

[Release Notes Link](https://kratapps.com/test-data-factory/release-notes)

## v1.5

Version ID: 04t09000000vCX2AAM

- Fix remove createable condition to merged records.
- Set relationship ID if record is provided.

```apex
CampaignMember member = (CampaignMember) factory.inserted(new CampaignMember(Campaign = campaign, Lead = lead)).toSObject();
// This would fail in previous versions.
Assert.areEqual(campaign.Id, member.CampaignId);
```

- Clear record ID from defaults and test provided records.

```apex
Contact contactWithId = (Contact) factory.inserted(new Contact()).toSObject();
// Next line would fail as the ID from test-provided record would be merged.
// The ID is now cleared from new records.
factory.inserted(contactWithId).toSObject();
```

## v1.4

Version ID: 04t09000000vCWn

- Fix issue #3 some Target and Factory Default values are not used.
- Change default value for all standard Quantity fields from 0 to 1.
- Enhance default SObject factory to support some standard objects out-of-the-box.
- Add unit tests for some standard objects.
- Add unit test to test managed package records.

## v1.3

Version ID: 04t09000000v7x7

- Fix custom metadata records creation.

## v1.2

Version ID: 04t09000000v7va

- Add Test_Data_Factory_Default\_\_mdt settings.

## v1.1

Version ID: 04t090000011mS6

- Available as unpackaged.

## v1.0

Version ID: 04t090000011fUi

- Initial Release.
