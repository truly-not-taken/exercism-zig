const std = @import("std");
const testing = std.testing;

const satellite = @import("satellite.zig");
const Tree = satellite.Tree;
const Result = (std.mem.Allocator.Error || satellite.TraversalError)!Tree;

fn expectEqualChars(expected: u8, actual: u8) !void {
    const fmtChar = std.zig.fmtChar;
    if (actual != expected) {
        testing.failPrint("expected '{f}', found '{f}'\n", .{
            fmtChar(expected),
            fmtChar(actual),
        });
        return error.TestExpectedEqual;
    }
}

test "Empty tree" {
    const preorder: []const u8 = "";
    const inorder: []const u8 = "";
    const actual: Tree = try .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer actual.deinit();
    const root = actual.root;
    try testing.expectEqual(null, root);
}

test "Tree with one item" {
    const preorder: []const u8 = "a";
    const inorder: []const u8 = "a";
    const actual: Tree = try .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer actual.deinit();
    const root = actual.root;
    try testing.expect(root != null);
    try expectEqualChars('a', root.?.data);
    try testing.expectEqual(null, root.?.left);
    try testing.expectEqual(null, root.?.right);
}

test "Tree with many items" {
    const preorder: []const u8 = "aixfr";
    const inorder: []const u8 = "iafxr";
    const actual: Tree = try .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer actual.deinit();
    const root = actual.root;
    try testing.expect(root != null);
    try expectEqualChars('a', root.?.data);
    try testing.expect(root.?.left != null);
    try expectEqualChars('i', root.?.left.?.data);
    try testing.expectEqual(null, root.?.left.?.left);
    try testing.expectEqual(null, root.?.left.?.right);
    try testing.expect(root.?.right != null);
    try expectEqualChars('x', root.?.right.?.data);
    try testing.expect(root.?.right.?.left != null);
    try expectEqualChars('f', root.?.right.?.left.?.data);
    try testing.expectEqual(null, root.?.right.?.left.?.left);
    try testing.expectEqual(null, root.?.right.?.left.?.right);
    try testing.expect(root.?.right.?.right != null);
    try expectEqualChars('r', root.?.right.?.right.?.data);
    try testing.expectEqual(null, root.?.right.?.right.?.left);
    try testing.expectEqual(null, root.?.right.?.right.?.right);
}

test "Reject traversals of different length" {
    const preorder: []const u8 = "ab";
    const inorder: []const u8 = "bar";
    const actual: Result = .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer if (actual) |a| a.deinit() else |_| {};
    try testing.expectError(error.DifferentLengths, actual);
}

test "Reject inconsistent traversals of same length" {
    const preorder: []const u8 = "xyz";
    const inorder: []const u8 = "abc";
    const actual: Result = .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer if (actual) |a| a.deinit() else |_| {};
    try testing.expectError(error.DifferentItems, actual);
}

test "Reject traversals with repeated items" {
    const preorder: []const u8 = "aba";
    const inorder: []const u8 = "baa";
    const actual: Result = .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer if (actual) |a| a.deinit() else |_| {};
    try testing.expectError(error.NonUniqueItems, actual);
}

test "A degenerate binary tree" {
    const preorder: []const u8 = "abcd";
    const inorder: []const u8 = "dcba";
    const actual: Tree = try .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer actual.deinit();
    const root = actual.root;
    try testing.expect(root != null);
    try expectEqualChars('a', root.?.data);
    try testing.expect(root.?.left != null);
    try expectEqualChars('b', root.?.left.?.data);
    try testing.expect(root.?.left.?.left != null);
    try expectEqualChars('c', root.?.left.?.left.?.data);
    try testing.expect(root.?.left.?.left.?.left != null);
    try expectEqualChars('d', root.?.left.?.left.?.left.?.data);
    try testing.expectEqual(null, root.?.left.?.left.?.left.?.left);
    try testing.expectEqual(null, root.?.left.?.left.?.left.?.right);
    try testing.expectEqual(null, root.?.left.?.left.?.right);
    try testing.expectEqual(null, root.?.left.?.right);
    try testing.expectEqual(null, root.?.right);
}

test "Another degenerate binary tree" {
    const preorder: []const u8 = "abcd";
    const inorder: []const u8 = "abcd";
    const actual: Tree = try .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer actual.deinit();
    const root = actual.root;
    try testing.expect(root != null);
    try expectEqualChars('a', root.?.data);
    try testing.expectEqual(null, root.?.left);
    try testing.expect(root.?.right != null);
    try expectEqualChars('b', root.?.right.?.data);
    try testing.expectEqual(null, root.?.right.?.left);
    try testing.expect(root.?.right.?.right != null);
    try expectEqualChars('c', root.?.right.?.right.?.data);
    try testing.expectEqual(null, root.?.right.?.right.?.left);
    try testing.expect(root.?.right.?.right.?.right != null);
    try expectEqualChars('d', root.?.right.?.right.?.right.?.data);
    try testing.expectEqual(null, root.?.right.?.right.?.right.?.left);
    try testing.expectEqual(null, root.?.right.?.right.?.right.?.right);
}

test "Tree with many more items" {
    const preorder: []const u8 = "abdghcefi";
    const inorder: []const u8 = "gdhbaecif";
    const actual: Tree = try .initFromTraversals(
        testing.allocator,
        preorder,
        inorder,
    );
    defer actual.deinit();
    const root = actual.root;
    try testing.expect(root != null);
    try expectEqualChars('a', root.?.data);
    try testing.expect(root.?.left != null);
    try expectEqualChars('b', root.?.left.?.data);
    try testing.expect(root.?.left.?.left != null);
    try expectEqualChars('d', root.?.left.?.left.?.data);
    try testing.expect(root.?.left.?.left.?.left != null);
    try expectEqualChars('g', root.?.left.?.left.?.left.?.data);
    try testing.expectEqual(null, root.?.left.?.left.?.left.?.left);
    try testing.expectEqual(null, root.?.left.?.left.?.left.?.right);
    try testing.expect(root.?.left.?.left.?.right != null);
    try expectEqualChars('h', root.?.left.?.left.?.right.?.data);
    try testing.expectEqual(null, root.?.left.?.left.?.right.?.left);
    try testing.expectEqual(null, root.?.left.?.left.?.right.?.right);
    try testing.expectEqual(null, root.?.left.?.right);
    try testing.expect(root.?.right != null);
    try expectEqualChars('c', root.?.right.?.data);
    try testing.expect(root.?.right.?.left != null);
    try expectEqualChars('e', root.?.right.?.left.?.data);
    try testing.expectEqual(null, root.?.right.?.left.?.left);
    try testing.expectEqual(null, root.?.right.?.left.?.right);
    try testing.expect(root.?.right.?.right != null);
    try expectEqualChars('f', root.?.right.?.right.?.data);
    try testing.expect(root.?.right.?.right.?.left != null);
    try expectEqualChars('i', root.?.right.?.right.?.left.?.data);
    try testing.expectEqual(null, root.?.right.?.right.?.left.?.left);
    try testing.expectEqual(null, root.?.right.?.right.?.left.?.right);
    try testing.expectEqual(null, root.?.right.?.right.?.right);
}
