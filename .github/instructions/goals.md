This Client API should be able to:

* List all publications a user can access.
* Publish a post to one of the user's publications.


In the example looks likes, the values are made up.

A publication looks like:

```json
{
  "id": 4,
  "title": "abc123",
  "displayTitle": "abc123",
  "descriptionSEO": "abc123",
  "about": Content,
  "url": "xyz789",
  "canonicalURL": "xyz789",
  "author": User,
  "favicon": "xyz789",
  "headerColor": "abc123",
  "metaTags": "abc123",
  "integrations": PublicationIntegrations,
  "invites": PublicationInvite,
  "preferences": Preferences,
  "followersCount": 123,
  "imprint": "abc123",
  "imprintV2": Content,
  "isTeam": true,
  "links": PublicationLinks,
  "domainInfo": DomainInfo,
  "isHeadless": true,
  "series": Series,
  "seriesList": SeriesConnection,
  "posts": PublicationPostConnection,
  "postsViaPage": PublicationPostPageConnection,
  "pinnedPost": Post,
  "post": Post,
  "redirectedPost": Post,
  "ogMetaData": OpenGraphMetaData,
  "features": PublicationFeatures,
  "drafts": DraftConnection,
  "allDrafts": DraftConnection,
  "scheduledDrafts": DraftConnection,
  "allScheduledDrafts": DraftConnection,
  "staticPage": StaticPage,
  "staticPages": StaticPageConnection,
  "submittedDrafts": DraftConnection,
  "isGitHubBackupEnabled": false,
  "isGithubAsSourceConnected": true,
  "urlPattern": "DEFAULT",
  "emailImport": EmailImport,
  "redirectionRules": [RedirectionRule],
  "hasBadges": true,
  "sponsorship": PublicationSponsorship,
  "recommendedPublications": [
    UserRecommendedPublicationEdge
  ],
  "totalRecommendedPublications": 987,
  "recommendingPublications": PublicationUserRecommendingPublicationConnection,
  "allowContributorEdits": true,
  "members": PublicationMemberConnection,
  "publicMembers": PublicationMemberConnection
}
```

A post looks like:

```json
{
  "id": "4",
  "slug": "abc123",
  "previousSlugs": ["abc123"],
  "title": "xyz789",
  "subtitle": "xyz789",
  "author": User,
  "coAuthors": [User],
  "tags": [Tag],
  "url": "abc123",
  "canonicalUrl": "xyz789",
  "publication": Publication,
  "cuid": "xyz789",
  "coverImage": PostCoverImage,
  "bannerImage": PostBannerImage,
  "brief": "abc123",
  "readTimeInMinutes": 987,
  "views": 987,
  "series": Series,
  "reactionCount": 123,
  "replyCount": 123,
  "responseCount": 123,
  "featured": false,
  "contributors": [User],
  "commenters": PostCommenterConnection,
  "comments": PostCommentConnection,
  "bookmarked": true,
  "content": Content,
  "likedBy": PostLikerConnection,
  "featuredAt": "2007-12-03T10:15:30Z",
  "publishedAt": "2007-12-03T10:15:30Z",
  "updatedAt": "2007-12-03T10:15:30Z",
  "preferences": PostPreferences,
  "audioUrls": AudioUrls,
  "seo": SEO,
  "ogMetaData": OpenGraphMetaData,
  "hasLatexInPost": true,
  "isFollowed": true,
  "isAutoPublishedFromRSS": false,
  "features": PostFeatures,
  "sourcedFromGithub": true
}
```