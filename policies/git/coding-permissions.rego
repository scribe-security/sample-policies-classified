package verify

import future.keywords.in

default allow := false

default violations := []

default props := []

default author := ""

default msg := "Some files are commited by unauthorized authors"

verify = v {
	v := {
		"allow": allow,
		"violations": violations,
		"summary": [{
			"allow": allow,
			"reason": msg,
			"violations": count(violations),
		}],
	}
}

allow {
	count(violations) == 0
}

msg = "All required files are commited by authorized authors" {
	allow
}

violations = j {
	j := {r |
		some file in input.config.args.files
		some object in input.evidence.predicate.bom.components
		object.type == "file"
		object.name == file
		some prop in object.properties
		prop.name == "last_commit"
		author := get_commit_author(prop.value)
		not any_match(author)
		r = {
			"type": "mismatching_author",
			"details": {
				"file": file,
				"author": author,
			},
		}
	}
}

any_match(author) {
	some id in input.config.args.ids
	contains(author, id)
}

get_commit_author(hash) := h {
	some object in input.evidence.predicate.bom.components
	object.type == "commit"
	object.name == hash
	some prop in object.properties
	prop.name == "Author"
	h := prop.value
}
