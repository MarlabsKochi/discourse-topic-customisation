import NavItemModel from "discourse/models/nav-item"

export default {
  name: 'extend-nav-item-model',
  initialize() {
  NavItemModel.reopen({
  displayName: function() {
    var categoryName = this.get('categoryName'),
        name = this.get('name'),
        count = 0;

    if(this.topicTrackingState.currentUser.admin){
     count = this.get('count') || 0;
    }

    if (name === 'latest' && !Discourse.Mobile.mobileView) {
      count = 0;
    }

    var extra = { count: count };
    var titleKey = count === 0 ? '.title' : '.title_with_count';

    if (categoryName) {
      name = 'category';
      extra.categoryName = toTitleCase(categoryName);
    }
    return I18n.t("filters." + name.replace("/", ".") + titleKey, extra);
  }.property('categoryName', 'name', 'count')
    });
  }
};