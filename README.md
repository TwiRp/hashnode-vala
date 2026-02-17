# hashnode-vala

This is questionable... I'm not sure how to use the Hashnode API. We just threw code at the wall until something stuck.

Unofficial [Hashnode](https://hashnode.com) API client library for Vala. Still a work in progress.

## Compilation

I recommend including `hashnode-vala` as a git submodule and adding `hashnode-vala/src/Hashnode.vala` to your sources list. This will avoid packaging conflicts and remote build system issues until I learn a better way to suggest this.

For libsoup3, use `hashnode-vala/src/Hashnode3.vala`.

### Requirements

```
meson
ninja-build
valac
```

### Building

```bash
meson build
cd build
meson configure -Denable_examples=true
ninja
./examples/hello-hashnode
```

Examples require update to publication id and [Personal Access Token](https://hashnode.com/settings/developer), don't check this in

```
string publication_id = "publication id";
string key = "personal-access-token";
```

# Quick Start

## New Login

```vala
string publication_id = "publication-id";
string key = "personal-access-token";

Hashnode.Client client = new Hashnode.Client ();
if (client.authenticate (
        publication_id,
        key))
{
    print ("Successfully logged in");
} else {
    print ("Could not login");
}
```

## Publish a Post

```vala
string url;
string id;
if (client.publish_post (
    out url,
    out id,
    "# Hello Hashnode!

Hello from [ThiefMD](https://thiefmd.com)!",
    "Hello Hashnode!"))
{
    print ("Made post: %s", url);
}
```

## Get Accessible Publications

```vala
GLib.List<Hashnode.PublicationResponse> publications = new GLib.List<Hashnode.PublicationResponse> ();
if (client.get_user_publications (ref publications)) {
    foreach (var publication in publications) {
        print ("Publication: %s (%s)\n", publication.title, publication.hashnodeId);
    }
}
```

## Publish to a Specific Publication

```vala
string url;
string id;
if (client.publish_publication_post (
    out url,
    out id,
    "publication-id",
    "# Hello Hashnode!\n\nHello from [ThiefMD](https://thiefmd.com)!",
    "Hello Hashnode!"))
{
    print ("Made post: %s", url);
}
```
