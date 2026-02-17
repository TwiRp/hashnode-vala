public class HelloHashnode {
    public static int main (string[] args) {
        string user_name = "publication-id";
        string password = "access-token";

        try {
            Hashnode.Client client = new Hashnode.Client ();

            print ("Step 1: Authenticating user...\n");
            if (client.authenticate (
                    user_name,
                    password))
            {
                print ("Step 1: Authentication successful.\n");
            } else {
                print ("Step 1: Authentication failed.\n");
                return 0;
            }

            print ("Step 2: Listing publications...\n");
            GLib.List<Hashnode.PublicationResponse> publications = new GLib.List<Hashnode.PublicationResponse> ();
            if (!client.get_user_publications (ref publications)) {
                print ("Step 2: Failed to fetch publications.\n");
                return 0;
            }

            if (publications.length () == 0) {
                print ("Step 2: No publications found.\n");
                return 0;
            }

            foreach (var publication in publications) {
                string host = publication.domainInfo != null && publication.domainInfo.domain != null
                    ? publication.domainInfo.domain.host
                    : publication.domain;
                print ("- %s (%s)\n", publication.title, host);
            }
            print ("Step 2: Listed %u publications.\n", publications.length ());

            print ("Step 3: Publishing a post to the first publication...\n");
            var first_publication = publications.nth_data (0);
            string target_publication_id = first_publication.hashnodeId;
            if (target_publication_id == "" || target_publication_id == null) {
                target_publication_id = first_publication.id;
            }

            string url;
            string id;
            if (client.publish_publication_post (
                out url,
                out id,
                target_publication_id,
                "# Hello Hashnode!\n\nHello from [ThiefMD](https://thiefmd.com)!",
                "Hello Hashnode!"))
            {
                print ("Step 3: Post published: %s\n", url);
            } else {
                print ("Step 3: Failed to publish post.\n");
            }

            print ("Step 4: Creating a draft post...\n");
            string draft_id;
            if (client.create_draft (
                out draft_id,
                target_publication_id,
                "# Demo Draft\n\nThis is a draft post.",
                "Demo Draft"))
            {
                print ("Step 4: Draft created with ID: %s\n", draft_id);

                print ("Step 5: Publishing the draft...\n");
                if (client.publish_draft (
                    out url,
                    out id,
                    draft_id))
                {
                    print ("Step 5: Draft published: %s\n", url);
                } else {
                    print ("Step 5: Failed to publish draft.\n");
                }
            } else {
                print ("Step 4: Failed to create draft.\n");
            }
        } catch (Error e) {
            warning ("Failed: %s", e.message);
        }
        return 0;
    }
}