import { acceptance } from "helpers/qunit-helpers";

acceptance("DiscourseAddToSummary", { loggedIn: true });

test("DiscourseAddToSummary works", async assert => {
  await visit("/admin/plugins/discourse-add-to-summary");

  assert.ok(false, "it shows the DiscourseAddToSummary button");
});
