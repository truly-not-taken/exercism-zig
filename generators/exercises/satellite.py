from lib import is_error

HEADER = """const Tree = satellite.Tree;
const Result = (std.mem.Allocator.Error || satellite.TraversalError)!Tree;

fn expectEqualChars(expected: u8, actual: u8) !void {
    const fmtChar = std.zig.fmtChar;
    if (actual != expected) {
        testing.failPrint("expected '{f}', found '{f}'\\n", .{
            fmtChar(expected),
            fmtChar(actual),
        });
        return error.TestExpectedEqual;
    }
}
"""

_ERROR_MAP = {
    "traversals must have the same length": "DifferentLengths",
    "traversals must have the same elements": "DifferentItems",
    "traversals must contain unique items": "NonUniqueItems",
}


def _u8_const_slice(name, chars):
    inner = "".join(chars)
    return f"const {name}: []const u8 = \"{inner}\";\n"

def _traverse(expr, node, out):
    if not node:
        out.append(f"try testing.expectEqual(null, {expr});\n")
        return
    out.append(f"try testing.expect({expr} != null);\n")
    out.append(f"try expectEqualChars('{node['v']}', {expr}.?.data);\n")
    _traverse(expr + ".?.left", node['l'],out)
    _traverse(expr + ".?.right", node['r'],out)

def gen_case(case):
    inp = case["input"]
    expected = case["expected"]
    preorder = inp["preorder"]
    inorder = inp["inorder"]

    out = [_u8_const_slice("preorder", preorder), _u8_const_slice("inorder", inorder)]

    if is_error(expected):
        out.append("""const actual: Result = .initFromTraversals(
            testing.allocator, preorder, inorder,);
            defer if (actual) |a| a.deinit() else |_| {};
            """)
        err = _ERROR_MAP[expected["error"]]
        out.append(f"try testing.expectError(error.{err}, actual);\n")
        return "".join(out)

    out.append("""const actual: Tree = try .initFromTraversals(
        testing.allocator, preorder, inorder,);
        defer actual.deinit();
        const root = actual.root;
        """)
    _traverse("root", expected, out)

    return "".join(out)
