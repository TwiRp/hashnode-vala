All Hashnode Public API queries are made through a single GraphQL endpoint, which only accepts POST requests.

https://gql.hashnode.com

The documentation is at
https://apidocs.hashnode.com

Almost all queries can be accessed without any authentication mechanism. Some sensitive fields need authentication. All mutations need an authentication header.

You can include an Authorization header in your request to access restricted fields. The value of the Authorization header needs to be your Personal Access Token (PAT).

The API supports Queries and Mutations.

## Examples

Querying a user's publications (kmwallio is the username):

```query {
  user(username:"kmwallio") {
    publications(first: 5) {
      edges {
        node {
          id
          domainInfo {
            domain {
              host
            }
          }
        }
      }
    }
  }
}
```

This wil return:

```json
{
  "data": {
    "user": {
      "publications": {
        "edges": [
          {
            "node": {
              "id": "62b366e386d22092a7546fb2",
              "domainInfo": {
                "domain": {
                  "host": "kmw.ninja"
                }
              }
            }
          },
          {
            "node": {
              "id": "62b3c9c986d22092a754784d",
              "domainInfo": {
                "domain": {
                  "host": "vala.lol"
                }
              }
            }
          }
        ]
      }
    }
  }
}
```

An example of a restricted query could be getting drafts inside any blog, it can only be queried by their respective owners.

```
query Publication($first: Int!, $host: String) {
    publication(host: $host) {
        drafts(first: $first) {
            edges {
                node {
                    title
                }
            }
        }
    }
}
```

Fetch details about your publication

```
query Publication {
    publication(host: "blog.developerdao.com") {
        isTeam
        title
        about {
            markdown
        }
    }
}
```

Fetch posts from your blog

```
query Publication {
    publication(host: "blog.developerdao.com") {
        isTeam
        title
        posts(first: 10) {
            edges {
                node {
                    title
                    brief
                    url
                }
            }
        }
    }
}
```

A mutation would look like:

```
mutation AddPostToSeries($input: AddPostToSeriesInput!) {
  addPostToSeries(input: $input) {
    series {
      id
      name
      createdAt
      description {
        ...ContentFragment
      }
      coverImage
      author {
        ...UserFragment
      }
      cuid
      slug
      sortOrder
      posts {
        ...SeriesPostConnectionFragment
      }
    }
  }
}
```