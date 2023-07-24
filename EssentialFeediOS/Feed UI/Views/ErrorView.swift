//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by LennartWisbar on 24.07.23.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var button: UIButton!

    public var message: String? {
        get { return button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        button.setTitle(nil, for: .normal)
    }}
