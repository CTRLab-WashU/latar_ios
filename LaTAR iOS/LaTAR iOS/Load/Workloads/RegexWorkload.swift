//
// RegexWorkload.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import Foundation

public class RegexWorkload: Workload
{
    private var regex:NSRegularExpression!;
    private var string:String = "";
    
    override func setup() {
        
        self.regex = try! NSRegularExpression(pattern: "(?<=r)d");
        self.string = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum sollicitudin porta massa, quis tempus ante bibendum eu. In sodales tempus luctus. Nunc rhoncus efficitur tellus id molestie. Morbi tincidunt ligula sit amet metus volutpat, in interdum felis consequat. Cras sit amet mi nisi. Curabitur vitae libero risus. Nullam nec lorem quis dui sagittis molestie ut quis felis. Etiam eu sapien vel massa pretium vestibulum. Morbi scelerisque justo ante. Suspendisse tempus iaculis sollicitudin. Aliquam ut tellus vehicula est accumsan fermentum nec at dolor. Nullam in nibh a sem faucibus volutpat eget at arcu.
Ut non velit ac felis porta sollicitudin et et dolor. Phasellus sed sodales justo. Maecenas at gravida sapien. Mauris blandit volutpat luctus. Ut convallis augue eu nisl accumsan vestibulum. Duis id quam eget leo sollicitudin luctus posuere quis tortor. Proin gravida laoreet ante et iaculis. Aliquam dui enim, laoreet eu tincidunt id, tristique non nunc. Vestibulum in ligula nibh. Praesent ex mauris, convallis vitae libero sed, aliquet aliquet ipsum. Fusce vitae facilisis orci. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque in tortor a leo convallis cursus.
Aliquam tincidunt in elit at tempor. Proin consectetur dictum orci, ac placerat dolor tincidunt ut. Mauris ornare pellentesque eros vitae pellentesque. Nulla pretium lectus dui, sed tempus lectus faucibus quis. Vestibulum dapibus id orci nec ultrices. Donec dui magna, aliquam vitae tincidunt in, tincidunt sed velit. Sed tincidunt ligula ut nulla dictum, quis varius nunc congue. Donec et suscipit nunc. Mauris finibus tincidunt sem vitae posuere. Quisque efficitur semper mauris, ut scelerisque augue. Curabitur eu maximus purus. Donec risus ante, ultrices non tincidunt id, facilisis ut sapien.
Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Etiam arcu magna, porta a placerat hendrerit, vulputate non nunc. Integer vel maximus purus. Nullam laoreet viverra bibendum. Quisque volutpat, dolor at rhoncus tincidunt, sem leo vehicula sem, eget vulputate mi tellus et lectus. Vivamus sed bibendum ligula. Mauris hendrerit ligula in est sagittis, quis pharetra justo porttitor. In hac habitasse platea dictumst. Nam id cursus nunc. Quisque elit eros, scelerisque in felis in, vestibulum gravida dui. Nullam purus neque, lobortis malesuada augue id, commodo ultrices urna. Nullam vitae velit fringilla, fringilla ipsum quis, viverra justo. Nulla odio nulla, pharetra in molestie iaculis, porta non quam. Curabitur cursus auctor odio, non commodo lectus feugiat sit amet. Ut suscipit aliquet elit eget efficitur. Aliquam erat volutpat.
Ut sed lacus nec lectus placerat semper tempus eget arcu. Suspendisse potenti. Donec tincidunt fringilla porta. Pellentesque posuere ac metus non interdum. Integer in efficitur neque. Etiam maximus diam ac quam vehicula, eu dapibus odio vulputate. Mauris sit amet orci vehicula, auctor quam id, ultrices leo. In fermentum cursus luctus. Nullam quis nibh placerat, facilisis tellus id, venenatis purus. Integer pharetra porta nulla at vestibulum. Integer sed felis nec mauris viverra gravida et eget purus. Vestibulum in efficitur arcu. Nunc rhoncus magna ut libero ornare tempus. Integer sem velit, sagittis non nunc nec, scelerisque imperdiet arcu.
"""
        
    }
    
    override func run() {
        let range = NSRange(location: 0, length: self.string.count);
        _ = self.regex.matches(in: self.string, options: [], range: range);
    }
    
    
}
