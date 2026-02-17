namespace Hashnode {
    public class Client {
        public string endpoint = "https://gql.hashnode.com";
        private string? authenticated_user;
        private string? authenticated_username;
        private string? authenticated_domain;
        private string? publication_id;

        public Client () {
            authenticated_user = null;
            authenticated_username = null;
        }

        private bool publish_post_internal (
            out string url,
            out string id,
            string target_publication_id,
            string content,
            string title,
            string main_image = "",
            string publishAs = "")
        {
            string auth_token = authenticated_user;
            url = "";
            id = "";
            bool published_post = false;

            if (auth_token == "" || target_publication_id == "") {
                return false;
            }

            CreateStoryInput new_post = new CreateStoryInput ();
            new_post.contentMarkdown = content;
            new_post.title = title;
            if (publishAs != "") {
                new_post.publishAs = publishAs;
            }
            if (main_image != "") {
                new_post.coverImageURL = main_image;
            }

            HashnodePost the_post = new HashnodePost ();
            HashnodeVariables the_vars = new HashnodeVariables ();
            the_post.query = "mutation createPublicationStory($input: CreateStoryInput!){ createPublicationStory(publicationId: \"%s\", input: $input){ code success message post { _id slug publication { domain } } } }".printf (target_publication_id);
            the_vars.input = new_post;
            the_post.variables = the_vars;

            Json.Node root = Json.gobject_serialize (the_post);
            Json.Generator generate = new Json.Generator ();
            generate.set_root (root);
            generate.set_pretty (false);
            // One day I'll find out how to do underscores...
            string request_body = generate.to_data (null).replace ("\"hashnodeId\"", "\"_id\"").replace ("\"title\"", "\"tags\": [], \"title\"");

            WebCall make_post = new WebCall (endpoint, "");
            make_post.set_post ();
            make_post.set_body (request_body);
            if (auth_token != "") {
                make_post.add_header ("Authorization", auth_token);
            }

            if (!make_post.perform_call ()) {
                warning ("Error: %u, %s", make_post.response_code, make_post.response_str);
                return false;
            }

            try {
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (make_post.response_str);
                Json.Node data = parser.get_root ();
                HashNodeResponse response = Json.gobject_deserialize (
                    typeof (HashNodeResponse),
                    data)
                    as HashNodeResponse;

                debug ("Deserialization was: %s", response != null ? "successful" : "failed");

                if (response != null) {
                    if (response.data != null && response.data.createPublicationStory != null) {
                        published_post = response.data.createPublicationStory.success;
                        if (authenticated_domain != null && authenticated_domain != "") {
                            url = "https://" + authenticated_domain + "/" + response.data.createPublicationStory.post.slug;
                        } else {
                            url = "https://" + response.data.createPublicationStory.post.publication.domain + "/" + response.data.createPublicationStory.post.slug;
                        }
                        id = response.data.createPublicationStory.post.hashnodeId;
                    }
                }

                if (!published_post) {
                    warning ("Sent: %s", request_body);
                    warning ("Got: %u, %s", make_post.response_code, make_post.response_str);
                }
            } catch (Error e) {
                warning ("Unable to publish post: %s", e.message);
            }

            return published_post;
        }

        public bool publish_post (
            out string url,
            out string id,
            string content,
            string title,
            string main_image = "",
            string publishAs = "")
        {
            return publish_post_internal (
                out url,
                out id,
                publication_id,
                content,
                title,
                main_image,
                publishAs);
        }

        public bool publish_publication_post (
            out string url,
            out string id,
            string target_publication_id,
            string content,
            string title,
            string main_image = "",
            string publishAs = "")
        {
            return publish_post_internal (
                out url,
                out id,
                target_publication_id,
                content,
                title,
                main_image,
                publishAs);
        }

        public bool authenticate (
            string publication,
            string pat) throws GLib.Error
        {
            // There's no way to validate authentication without
            // trying to do something on the user's behalf.
            publication_id = get_publication_id (publication);
            authenticated_user = pat;
            authenticated_username = publication;

            return true;
        }

        public string get_publication_id (string username) {
            string publication_id = username;
            string domain = "";
            if (!get_user_information (username,
                out publication_id,
                out domain))
            {
                publication_id = username;
                authenticated_domain = domain;
            }

            return publication_id;
        }

        public bool get_user_information (
            string username,
            out string publication_id,
            out string domain
            )
        {
            publication_id = username;
            domain = "";

            HashnodePost the_query = new HashnodePost ();
            the_query.query = "query user { user(username: \"%s\"){ publications(first: 1) { edges { node { id domainInfo { domain { host } } } } } } }".printf (username);

            Json.Node root = Json.gobject_serialize (the_query);
            Json.Generator generate = new Json.Generator ();
            generate.set_root (root);
            generate.set_pretty (false);
            // One day I'll find out how to do underscores...
            string request_body = generate.to_data (null).replace ("\"hashnodeId\"", "\"_id\"");

            WebCall make_post = new WebCall (endpoint, "");
            make_post.set_post ();
            make_post.set_body (request_body);

            if (!make_post.perform_call ()) {
                warning ("Error: %u, %s", make_post.response_code, make_post.response_str);
                return false;
            }

            try {
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (make_post.response_str);
                Json.Node data = parser.get_root ();
                HashNodeResponse response = Json.gobject_deserialize (
                    typeof (HashNodeResponse),
                    data)
                    as HashNodeResponse;

                if (response != null && response.data != null && response.data.user != null) {
                    var pubs = response.data.user.publications;
                    if (pubs != null && pubs.edges != null && pubs.edges.length > 0) {
                        var node = pubs.edges[0].node;
                        if (node != null) {
                            if (node.hashnodeId != null && node.hashnodeId != "") {
                                publication_id = node.hashnodeId;
                                domain = node.domainInfo != null && node.domainInfo.domain != null
                                    ? node.domainInfo.domain.host
                                    : node.domain;
                                return true;
                            }
                            if (node.id != null && node.id != "") {
                                publication_id = node.id;
                                domain = node.domainInfo != null && node.domainInfo.domain != null
                                    ? node.domainInfo.domain.host
                                    : node.domain;
                                return true;
                            }
                        }
                    }
                }
            } catch (Error e) {
                warning ("Unable to publish post: %s", e.message);
            }

            return false;
        }

        public bool get_user_publications (
            ref GLib.List<PublicationResponse> publications
            )
        {
            publications = new GLib.List<PublicationResponse> ();
            string auth_token = authenticated_user;
            string auth_username = authenticated_username;
            if ((auth_token == null || auth_token == "") && (auth_username == null || auth_username == "")) {
                return false;
            }

            HashnodePost the_query = new HashnodePost ();
            if (auth_username != null && auth_username != "") {
                the_query.query = "query user { user(username: \"%s\"){ publications(first: 50) { edges { node { id title domainInfo { domain { host } } } } } } }".printf (auth_username);
            } else {
                the_query.query = "query me { me { publications(first: 50) { edges { node { id title domainInfo { domain { host } } } } } } }";
            }

            Json.Node root = Json.gobject_serialize (the_query);
            Json.Generator generate = new Json.Generator ();
            generate.set_root (root);
            generate.set_pretty (false);
            string request_body = generate.to_data (null).replace ("\"hashnodeId\"", "\"_id\"");

            WebCall make_post = new WebCall (endpoint, "");
            make_post.set_post ();
            make_post.set_body (request_body);
            if (auth_token != null && auth_token != "") {
                make_post.add_header ("Authorization", auth_token);
            }

            if (!make_post.perform_call ()) {
                warning ("Error: %u, %s", make_post.response_code, make_post.response_str);
                return false;
            }

            try {
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (make_post.response_str);
                Json.Node data = parser.get_root ();
                HashNodeResponse response = Json.gobject_deserialize (
                    typeof (HashNodeResponse),
                    data)
                    as HashNodeResponse;

                if (response != null && response.data != null) {
                    PublicationsConnection pubs = null;
                    if (response.data.user != null) {
                        pubs = response.data.user.publications;
                    } else if (response.data.me != null) {
                        pubs = response.data.me.publications;
                    }
                    if (pubs != null && pubs.edges != null) {
                        foreach (var edge in pubs.edges) {
                            if (edge != null && edge.node != null) {
                                publications.append (edge.node);
                            }
                        }
                        return true;
                    }
                }

                Json.Object root_object = data.get_object ();
                if (root_object == null) {
                    return false;
                }

                Json.Object data_object = root_object.get_object_member ("data");
                if (data_object == null) {
                    return false;
                }

                Json.Object user_object = null;
                if (auth_username != null && auth_username != "") {
                    user_object = data_object.get_object_member ("user");
                } else if (data_object.has_member ("me")) {
                    user_object = data_object.get_object_member ("me");
                }

                if (user_object == null) {
                    return false;
                }

                Json.Object publications_object = user_object.get_object_member ("publications");
                if (publications_object == null) {
                    return false;
                }

                Json.Array edges = publications_object.get_array_member ("edges");
                if (edges == null) {
                    return false;
                }

                for (uint i = 0; i < edges.get_length (); i++) {
                    Json.Object edge_object = edges.get_object_element (i);
                    if (edge_object == null) {
                        continue;
                    }
                    Json.Object node_object = edge_object.get_object_member ("node");
                    if (node_object == null) {
                        continue;
                    }

                    PublicationResponse publication = new PublicationResponse ();
                    publication.id = node_object.get_string_member ("id");
                    publication.title = node_object.get_string_member ("title");

                    Json.Object domain_info_object = node_object.get_object_member ("domainInfo");
                    if (domain_info_object != null) {
                        Json.Object domain_object = domain_info_object.get_object_member ("domain");
                        if (domain_object != null) {
                            DomainResponse domain_response = new DomainResponse ();
                            domain_response.host = domain_object.get_string_member ("host");

                            DomainInfoResponse domain_info = new DomainInfoResponse ();
                            domain_info.domain = domain_response;

                            publication.domainInfo = domain_info;
                            publication.domain = domain_response.host;
                        }
                    }

                    publications.append (publication);
                }

                return publications.length () > 0;
            } catch (Error e) {
                warning ("Unable to fetch publications: %s", e.message);
            }

            return false;
        }
    }

    public class Response : GLib.Object, Json.Serializable {
    }

    public class HashNodeResponse : Response {
        public HashNodeData data { get; set; }
    }

    public class HashNodeData : Response {
        public CreatePostOutput createPublicationStory { get; set; }
        public PublishPostPayload publishPost { get; set; }
        public UserOutput user { get; set; }
        public MeOutput me { get; set; }
    }

    public class PublishPostPayload : Response {
        public PostResponse post { get; set; }
    }

    public class PostResponse : Response {
        public string id { get; set; }
        public string hashnodeId { get; set; }
        public string slug { get; set; }
        public string url { get; set; }
        public PublicationResponse publication { get; set; }
    }

    public class UserOutput : Response {
        public PublicationsConnection publications { get; set; }
    }

    public class MeOutput : Response {
        public PublicationsConnection publications { get; set; }
    }

    public class PublicationsConnection : Response {
        public PublicationEdge[] edges { get; set; }
    }

    public class PublicationEdge : Response {
        public PublicationResponse node { get; set; }
    }

    public class CreatePostOutput : Response {
        public int code { get; set; }
        public bool success { get; set; }
        public string message { get; set; }
        public PostDetailedResponse post { get; set; }
    }

    public class PostDetailedResponse : Response {
        public string hashnodeId { get; set; }
        public string cuid { get; set; }
        public string slug { get; set; }
        public string title { get; set; }
        public bool partOfPublication { get; set; }
        public PublicationResponse publication { get; set; }
        public string dateUpdated { get; set; }
        public int totalReactions { get; set; }
        public int numCollapsed { get; set; }
        public string author { get; set; }
    }

    public class PublicationResponse : Response {
        public string id { get; set; }
        public string hashnodeId { get; set; }
        public string author { get; set; }
        public string username { get; set; }
        public string meta { get; set; }
        public string title { get; set; }
        public string domain { get; set; }
        public DomainInfoResponse domainInfo { get; set; }
    }

    public class DomainInfoResponse : Response {
        public DomainResponse domain { get; set; }
    }

    public class DomainResponse : Response {
        public string host { get; set; }
    }

    public class HashnodePost : GLib.Object, Json.Serializable {
        public string query { get; set; }
        public HashnodeVariables variables { get; set; }
    }

    public class HashnodeVariables : GLib.Object, Json.Serializable {
        public PublishPostInput input { get; set; }
        public string publicationId { get; set; }
    }

    public class PublishPostInput : GLib.Object, Json.Serializable {
        public string title { get; set; }
        public string publicationId { get; set; }
        public string contentMarkdown { get; set; }
        public string subtitle { get; set; }
        public string publishAs { get; set; }
        public string slug { get; set; }
        public string originalArticleURL { get; set; }
        public PublishPostTagInput[] tags { get; set; }
        public bool disableComments { get; set; }
        public CoverImageOptionsInput coverImageOptions { get; set; }
        public BannerImageOptionsInput bannerImageOptions { get; set; }
    }

    public class PublishPostTagInput : GLib.Object, Json.Serializable {
        public string? id { get; set; }
        public string? slug { get; set; }
        public string? name { get; set; }
    }

    public class CoverImageOptionsInput : GLib.Object, Json.Serializable {
        public string? url { get; set; }
        public string? coverImageURL { get; set; }
        public bool isCoverAttributionHidden { get; set; }
        public string? coverImageAttribution { get; set; }
        public string? coverImagePhotographer { get; set; }
        public bool stickCoverToBottom { get; set; }
    }

    public class BannerImageOptionsInput : GLib.Object, Json.Serializable {
        public string? bannerImageURL { get; set; }
    }

    public class CreateStoryInput : GLib.Object, Json.Serializable {
        public string title { get; set; }
        public string slug { get; set; }
        public string contentMarkdown { get; set; }
        public string coverImageURL { get; set; }
        public bool isRepublished { get; set; }
        public bool isAnonymous { get; set; }
        public string subtitle { get; set; }
        public string publishAs { get; set; }
        public TagData[] tags { get; set; }
    }

    public class TagData : GLib.Object, Json.Serializable {
        public string? hashnodeId { get; set; }
        public string? slug { get; set; }
        public string? name { get; set; }
    }

    private class WebCall {
        private Soup.Session session;
        private Soup.Message message;
        private string url;
        private string body;
        private bool is_mime = false;

        public string response_str;
        public uint response_code;

        public WebCall (string endpoint, string api) {
            url = endpoint + api;
            session = new Soup.Session ();
            body = "";
        }

        public void set_body (string data) {
            body = data;
        }

        public void set_multipart (Soup.Multipart multipart) {
            message = new Soup.Message.from_multipart (url, multipart);
            is_mime = true;
        }

        public void set_get () {
            message = new Soup.Message ("GET", url);
        }

        public void set_delete () {
            message = new Soup.Message ("DELETE", url);
        }

        public void set_post () {
            message = new Soup.Message ("POST", url);
        }

        public void add_header (string key, string value) {
            message.request_headers.append (key, value);
        }

        public bool perform_call () {
            MainLoop loop = new MainLoop ();
            bool success = false;
            debug ("Calling %s", url);

            add_header ("User-Agent", "hashnode-vala/0.1");
            if (body != "") {
                Bytes body_bytes = new Bytes.static (body.data);
                message.set_request_body_from_bytes ("application/json", body_bytes);
            } else {
                if (!is_mime) {
                    add_header ("Content-Type", "application/json");
                }
            }

            session.send_and_read_async.begin (message, 0, null, (obj, res) => {
                try {
                    var response = session.send_and_read_async.end (res);
                    response_str = response != null ? (string)response.get_data () : "";
                    response_str = response_str.replace ("\"_id\"", "\"hashnodeId\"");
                    response_code = message.status_code;

                    if (response_str != null && response_str != "") {
                        debug ("Non-empty body");
                    }

                    if (response_code >= 200 && response_code <= 250) {
                        success = true;
                        debug ("Success HTTP code");
                    }
                } catch (Error e) {
                    warning ("Error sending request: %s", e.message);
                }
                loop.quit ();
            });

            loop.run ();
            return success;
        }
    }
}