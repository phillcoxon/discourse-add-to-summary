import { withPluginApi } from "discourse/lib/plugin-api";

function initializeDiscourseAddToSummary(api) {
  
  // see app/assets/javascripts/discourse/lib/plugin-api
  // for the functions available via the api object
  
}

export default {
  name: "discourse-add-to-summary",

  initialize() {
    withPluginApi("0.8.24", initializeDiscourseAddToSummary);
  }
};
