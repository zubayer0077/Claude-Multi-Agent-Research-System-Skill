#!/bin/bash
# ==========================================================================
# SOURCE: multi-agent-research project (2025-11-16)
# NOTE: This test script validates the research skill hook router.
#       To run, you need the internet-search-router.sh hook installed.
# ==========================================================================
#
# Phase 1 Test Queries - 30+ queries across 7 edge case categories
# Based on DESIGN_DECISIONS.md Decision 4

ROUTER=".claude/hooks/user-prompt-submit/internet-search-router.sh"
PASSED=0
FAILED=0

echo "=== Phase 1: Hook Router Testing ==="
echo "Testing 30+ queries across 7 edge case categories"
echo ""

# Category 1: Standard Queries (4 queries)
echo "Category 1: Standard Queries"
test_query() {
    local query="$1"
    local should_detect="$2"  # "yes" or "no"

    result=$(echo "{\"text\": \"$query\"}" | $ROUTER 2>/dev/null)

    if [ "$should_detect" = "yes" ]; then
        if echo "$result" | grep -q "ROUTING DIRECTIVE"; then
            echo "  ✓ PASS: \"$query\""
            ((PASSED++))
        else
            echo "  ✗ FAIL: \"$query\" (should detect but didn't)"
            ((FAILED++))
        fi
    else
        if echo "$result" | grep -q "ROUTING DIRECTIVE"; then
            echo "  ✗ FAIL: \"$query\" (should NOT detect but did)"
            ((FAILED++))
        else
            echo "  ✓ PASS: \"$query\" (correctly passed through)"
            ((PASSED++))
        fi
    fi
}

test_query "Research WebRTC security" "yes"
test_query "Analyze cloud gaming latency optimization" "yes"
test_query "What is quantum computing?" "yes"
test_query "Investigate machine learning trends" "yes"
echo ""

# Category 2: Queries with Quotes (4 queries)
echo "Category 2: Queries with Quotes"
test_query "Research \"quantum computing\" applications" "yes"
test_query "What is \"WebRTC\" and how does it work?" "yes"
test_query "Analyze 'edge computing' vs 'cloud computing'" "yes"
test_query "I want to learn about \"mini-apps\" in super-apps" "yes"
echo ""

# Category 3: Special Characters (5 queries)
echo "Category 3: Special Characters"
test_query "Analyze cost & benefit" "yes"
test_query "Research C++ vs Rust performance" "yes"
test_query "What is \$PATH in bash?" "yes"
test_query "Investigate @mentions and #hashtags" "yes"
test_query "Research APIs: REST, GraphQL, gRPC" "yes"
echo ""

# Category 4: Verb Derivatives (10 queries)
echo "Category 4: Verb Derivatives"
test_query "searching machine learning" "yes"
test_query "researching WebRTC protocols" "yes"
test_query "exploring quantum algorithms" "yes"
test_query "gathering data about cloud platforms" "yes"
test_query "studied blockchain security" "yes"
test_query "analyzed market trends" "yes"
test_query "discovers new techniques" "yes"
test_query "learning about AI" "yes"
test_query "examining the evidence" "yes"
test_query "comparing different approaches" "yes"
echo ""

# Category 5: Question Patterns (3 queries)
echo "Category 5: Question Patterns"
test_query "How does WebRTC work?" "yes"
test_query "Why is quantum computing important?" "yes"
test_query "When did cloud gaming start?" "yes"
echo ""

# Category 6: Phrase Patterns (3 queries)
echo "Category 6: Phrase Patterns"
test_query "Find information about machine learning" "yes"
test_query "Look up quantum computing basics" "yes"
test_query "Search for WebRTC tutorials" "yes"
echo ""

# Category 7: Non-Research Queries (3 queries)
echo "Category 7: Non-Research Queries (Negative Tests)"
test_query "Fix the bug in login.js" "no"
test_query "Commit the changes" "no"
test_query "Create a new skill" "no"
echo ""

# Summary
echo "=== Test Summary ==="
echo "Total tests: $((PASSED + FAILED))"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ ALL TESTS PASSED"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    exit 1
fi
