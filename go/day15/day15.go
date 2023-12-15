package main

import (
	"bufio"
	"bytes"
	_ "embed"
	"fmt"
	"slices"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

// //go:embed day15.example.txt
//
//go:embed day15.txt
var data []byte

func main() {
	var timer = time.Now()

	var part1 uint
	var hm HashMap

	scanner := bufio.NewScanner(bytes.NewReader(data))
	scanner.Split(SplitComma)

	for scanner.Scan() {
		step := scanner.Text()

		if len(step) == 0 {
			continue
		}

		part1 += uint(hash(step))
		if err := hm.RunStep(step); err != nil {
			panic(err)
		}
	}

	fmt.Printf("day15 part1: %d\n", part1)
	fmt.Printf("day15 part2: %d\n", hm.Power())
	fmt.Printf("day15 all main(): %s\n", time.Since(timer))

}

func SplitComma(data []byte, atEOF bool) (advance int, token []byte, err error) {
	// Skip leading spaces.
	start := 0
	for width := 0; start < len(data); start += width {
		var r rune
		r, width = utf8.DecodeRune(data[start:])
		if r != ',' {
			break
		}
	}
	// Scan until space, marking end of word.
	for width, i := 0, start; i < len(data); i += width {
		var r rune
		r, width = utf8.DecodeRune(data[i:])
		if r == ',' {
			return i + width, data[start:i], nil
		}
	}
	// If we're at EOF, we have a final, non-empty, non-terminated word. Return it.
	if atEOF && len(data) > start {
		return len(data), data[start:], nil
	}
	// Request more data.
	return start, nil, nil
}

func hash(s string) uint8 {
	var out uint16

	for _, c := range s {
		out += uint16(c)
		out *= 17
		out %= 256
	}

	return uint8(out)
}

type Lens struct {
	label string
	power uint8
}

type HashMap struct {
	slots [256][]Lens
}

func (h *HashMap) RunStep(step string) error {
	opIdx := strings.IndexAny(step, "=-")
	label := step[0:opIdx]
	slot := hash(label)
	op := step[opIdx]

	switch op {
	case '=':
		{
			p_str := step[opIdx+1:]
			p, err := strconv.ParseInt(p_str, 10, 8)
			if err != nil {
				return err
			}

			found := false
			for i := range h.slots[slot] {
				if h.slots[slot][i].label == label {
					h.slots[slot][i].power = uint8(p)
					found = true
					break

				}
			}

			if !found {
				h.slots[slot] = append(h.slots[slot], Lens{
					label: label,
					power: uint8(p),
				})
			}
		}
	case '-':
		{
			for i := range h.slots[slot] {
				if h.slots[slot][i].label == label {
					h.slots[slot] = slices.Delete(h.slots[slot], i, i+1)
					break
				}
			}
		}
	default:
		return fmt.Errorf("Invalid operator")
	}

	return nil
}

func (h *HashMap) Power() uint {
	var out uint
	for slotIdx, s := range h.slots {
		for lensIdx, l := range s {
			out += uint((1 + slotIdx) * (1 + lensIdx) * int(l.power))
		}
	}
	return out
}
