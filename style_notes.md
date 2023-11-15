# Style Notes
- Ensure content is double-nested in &lt;section&gt; tags. The outer section handles the white background treatment, while the inner one gets text padding applied. This applies mainly to your intro content slides, which arent in an external file.
- add class="[color]" replacing [color] with red, green, or blue (default) to swap colors.
- iframes need to be in their own section file since the styles are applied to the top-level &lt;section&gt;
- To hide the background, add class="no-bg" to the outer section in your .j2 file.
- You may need to adjust some of your font headers to allow content to fit, or add style="margin-bottom:0" to the header tag.