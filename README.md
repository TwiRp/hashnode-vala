# hashnode-vala

This is questionable... I'm not sure how to use the Hashnode API. We just threw code at the wall until something stuck.

Unofficial [Hashnode](https://hashnode.com) API client library for Vala. Still a work in progress.

## Compilation

I recommend including `hashnode-vala` as a git submodule and adding `hashnode-vala/src/Hashnode.vala` to your sources list. This will avoid packaging conflicts and remote build system issues until I learn a better way to suggest this.

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
