namespace Hashnode {
    public class Client {
        public string endpoint = "https://api.hashnode.com/";
        private string? authenticated_user;
        private string? publication_id;

        public Client () {
            authenticated_user = null;
        }

        public bool publish_post (
            out string url,
            out string id,
            string content,
            string title,
            string main_image = "",
            string publishAs = "")
        {
            string auth_token = authenticated_user;
            url = "";
            id = "";
            bool published_post = false;

            if (auth_token == "" || publication_id == "") {
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
            the_post.query = "mutation createPublicationStory($input: CreateStoryInput!){ createPublicationStory(publicationId: \"%s\", input: $input){ code success message post { _id slug publication { domain } } } }".printf (publication_id);
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

            warning ("Got: %u, %s", make_post.response_code, make_post.response_str);

            try {
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (make_post.response_str);
                Json.Node data = parser.get_root ();
                HashNodeResponse response = Json.gobject_deserialize (
                    typeof (HashNodeResponse),
                    data)
                    as HashNodeResponse;

                warning ("Deserialization was: %s", response != null ? "successful" : "failed");

                if (response != null) {
                    published_post = response.data.createPublicationStory.success;
                    url = "https://" + response.data.createPublicationStory.post.publication.domain + "/" + response.data.createPublicationStory.post.slug;
                    id = response.data.createPublicationStory.post.hashnodeId;
                }
            } catch (Error e) {
                warning ("Unable to publish post: %s", e.message);
            }

            return published_post;
        }

        public bool authenticate (
            string publication,
            string pat) throws GLib.Error
        {
            // There's no way to validate authentication without
            // trying to do something on the user's behalf.
            publication_id = publication;
            authenticated_user = pat;

            return true;
        }
    }

    public class Response : GLib.Object, Json.Serializable {
    }

    public class HashNodeResponse : Response {
        public HashNodeData data { get; set; }
    }

    public class HashNodeData : Response {
        public CreatePostOutput createPublicationStory { get; set; }
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
        public string hashnodeId { get; set; }
        public string author { get; set; }
        public string username { get; set; }
        public string meta { get; set; }
        public string title { get; set; }
        public string domain { get; set; }
    }

    public class HashnodePost : GLib.Object, Json.Serializable {
        public string query { get; set; }
        public HashnodeVariables variables { get; set; }
    }

    public class HashnodeVariables : GLib.Object, Json.Serializable {
        public CreateStoryInput input { get; set; }
        public string publicationId { get; set; }
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

        public class WebCall (string endpoint, string api) {
            url = endpoint + api;
            session = new Soup.Session ();
            body = "";
        }

        public void set_body (string data) {
            body = data;
        }

        public void set_multipart (Soup.Multipart multipart) {
            message = Soup.Form.request_new_from_multipart (url, multipart);
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
                message.set_request ("application/json", Soup.MemoryUse.COPY, body.data);
            } else {
                if (!is_mime) {
                    add_header ("Content-Type", "application/json");
                }
            }

            session.queue_message (message, (sess, mess) => {
                response_str = (string) mess.response_body.flatten ().data;
                response_str = response_str.replace ("\"_id\"", "\"hashnodeId\"");
                response_code = mess.status_code;

                if (response_str != null && response_str != "") {
                    debug ("Non-empty body");
                }

                if (response_code >= 200 && response_code <= 250) {
                    success = true;
                    debug ("Success HTTP code");
                }
                loop.quit ();
            });

            loop.run ();
            return success;
        }
    }
}
