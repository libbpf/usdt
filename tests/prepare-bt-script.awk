# SPDX-License-Identifier: BSD-2-Clause

# Example inputs:
# group:name { some %s fmt %d spec %d -> str(arg0), (int)arg1, arg2 - 10 }
{
	if (!has_contents)
		printf("BEGIN { printf(\"STARTED!\\n\"); }\n");
	has_contents = 1;

	# Extract group and name
	split($1, parts, ":");
	group = parts[1];
	name = parts[2];

	# Split between { and }, extract insides of { }
	split($0, parts, /[{}]/)
	stmt_spec = parts[2]
	gsub(/^[ \t]+|[ \t]+$/, "", stmt_spec) # trim trailing whitespaces

	# Split by (optional) ->, trim spaces, extract fmt spec and args
	split(stmt_spec, stmt_parts, "->");
	fmt = stmt_parts[1];
	args = stmt_parts[2];
	gsub(/^[ \t]+|[ \t]+$/, "", fmt) # trim trailing whitespaces
	gsub(/^[ \t]+|[ \t]+$/, "", args) # trim trailin whitespaces

	# Emit corresponding bpftrace probe spec:
	# U:./test:group:name { printf("%s: some %s fmt %d spec %d\n", probe, str(arg0), (int)arg1, arg2 - 10); }
	printf("U:./%s:%s:%s { printf(\"%s:%s: %s\\n\"%s); }\n",
	       TEST, group, name, group, name, fmt, args == "" ? "" : ", " args);
}

END {
	if (has_contents)
		printf("END { printf(\"DONE!\\n\"); }\n");
}
