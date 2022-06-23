public class HelloHashnode {
    public static int main (string[] args) {
        string publication_id = "publication-id";
        string password = "access-token";

        try {
            Hashnode.Client client = new Hashnode.Client ();
            if (client.authenticate (
                    publication_id,
                    password))
            {
                print ("Successfully logged in\n");
            } else {
                print ("Could not login");
                return 0;
            }

            string url;
            string id;
            if (client.publish_post (
                out url,
                out id,
                "# Hello Hashnode!

Hello from [ThiefMD](https://thiefmd.com)!",
                "Hello Hashnode!"))
            {
                print ("Made post: %s\n", url);
            }
        } catch (Error e) {
            warning ("Failed: %s", e.message);
        }
        return 0;
    }
}